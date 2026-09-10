-- Language servers.
--
-- Neovim 0.11 moved LSP configuration into core: `vim.lsp.config` registers a
-- server and `vim.lsp.enable` starts it against matching buffers. nvim-lspconfig
-- is still here, but only as the community's collection of `lsp/*.lua` defaults
-- feeding that mechanism -- so the definitions below say nothing more than where
-- this setup differs from those defaults.

-- Capabilities are advertised once, for every server, rather than being
-- threaded through each definition.
--
-- The second argument is what merges blink's completion capabilities into
-- Neovim's defaults instead of returning them on their own. It matters more
-- than it looks: this table replaces the defaults outright, so passing false
-- told every server that the client supported nothing beyond completion --
-- no publishDiagnostics, no workspace/configuration, no file watching, and
-- no inlayHint refreshSupport, which is the one that bites. Without it a
-- server cannot ask for hints to be re-sent, so the single request made when
-- it attaches is the only one there will ever be, and an empty answer from a
-- server still loading its workspace stands for the life of the buffer.
vim.lsp.config("*", {
  capabilities = require("blink.cmp").get_lsp_capabilities({}, true),
})

-- rust-analyzer.
--
-- `--profile lsp` keeps the server's own `cargo check` out of the same target
-- directory the command line uses, so an editor check and a terminal build do
-- not block on each other's lock. Requires a [profile.lsp] in Cargo.toml, or
-- cargo falls back to dev.
vim.lsp.config("rust_analyzer", {
  settings = {
    ["rust-analyzer"] = {
      cargo = {
        allTargets = true,
        extraArgs = { "--profile", "lsp" },
      },
      check = {
        command = "clippy",
      },
    },
  },
})

-- python-lsp-server.
--
-- The pylsp-mypy and python-lsp-ruff plugins are installed alongside it, so
-- mypy and ruff report through pylsp rather than as separate linters. pylsp's
-- own bundled checkers are switched off because ruff already covers them and
-- would otherwise double-report every finding.
vim.lsp.config("pylsp", {
  settings = {
    pylsp = {
      plugins = {
        pylsp_mypy = { enabled = true },
        ruff = { enabled = true },
        pycodestyle = { enabled = false },
        pyflakes = { enabled = false },
        mccabe = { enabled = false },
        autopep8 = { enabled = false },
        yapf = { enabled = false },
      },
    },
  },
})

-- chicken-lsp-server.
--
-- No upstream definition exists for this one. Root detection prefers a CHICKEN
-- egg or setup file and falls back to the VCS root, so a scratch file outside
-- any project still gets a server rooted at its own directory.
local function chicken_root(bufnr, on_dir)
  local start = vim.fs.dirname(vim.api.nvim_buf_get_name(bufnr))
  if start == "" or start == nil then
    return
  end

  local egg = vim.fs.find(function(name)
    return name:match("%.egg$") ~= nil or name:match("%.setup$") ~= nil
  end, { path = start, upward = true, type = "file" })[1]

  if egg then
    return on_dir(vim.fs.dirname(egg))
  end

  local git = vim.fs.find(".git", { path = start, upward = true })[1]
  if git then
    return on_dir(vim.fs.dirname(git))
  end

  on_dir(start)
end

--
-- This server takes its hover text and signatures from chicken-doc rather
-- than from the buffer, and verifies that repository during the initialize
-- handshake -- without one it exits 70 before answering anything. The
-- repository and the CHICKEN_DOC_REPOSITORY that points at it are set up in
-- software.nix; see the comment there for why it cannot live in CHICKEN's
-- own directory on this system.
vim.lsp.config("chicken_lsp", {
  cmd = { "chicken-lsp-server", "--stdio" },
  filetypes = { "scheme" },
  root_dir = chicken_root,
})

-- nixd.
--
-- The upstream definition supplies the command and root markers; everything
-- below is the evaluation nixd needs in order to say anything useful, and it
-- is written against channels because that is what this system uses. `expr`
-- strings are evaluated by nixd itself, not here.
--
-- The options expression evaluates this very configuration, through the
-- /etc/nixos symlink, so completing a `services.*` or `boot.*` attribute
-- offers the real option set with its documentation and defaults. That makes
-- the evaluation as expensive as a rebuild the first time it is asked for.
vim.lsp.config("nixd", {
  settings = {
    nixd = {
      nixpkgs = { expr = "import <nixpkgs> { }" },

      options = {
        nixos = {
          expr = "(import <nixpkgs/nixos> { configuration = /etc/nixos/configuration.nix; }).options",
        },
      },
    },
  },
})

-- clojure_lsp and tofu_ls are taken entirely from nvim-lspconfig: their
-- defaults already look for deps.edn/project.clj/build.boot and
-- .terraform/.git respectively, which is what the ALE configuration
-- was reproducing by hand.
vim.lsp.enable({
  "chicken_lsp",
  "clojure_lsp",
  "nixd",
  "pylsp",
  "rust_analyzer",
  "tofu_ls",
})

-- Reference highlighting is registered per buffer as a server attaches and
-- torn down again on detach, so the group is made once here rather than
-- inside the callback: LspDetach needs to name it whether or not any server
-- turned out to support the method.
local highlight = vim.api.nvim_create_augroup("chris.lsp.highlight", { clear = true })

-- Buffer-local behaviour, applied as each server attaches.
--
-- Only `gd` is bound here, opening the definition in a vertical split as the
-- ALE mapping did. Rename, code action and references are deliberately left
-- to Neovim's own defaults -- grn, gra, grr and gri -- which a mapping on
-- `gr` would shadow, costing a timeout on every one of them. Hover is core's
-- too: it binds K on attach, given that `keywordprg` is left alone and
-- nothing else claims the key, so neither is bound here.
vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("chris.lsp.attach", { clear = true }),
  callback = function(args)
    vim.keymap.set("n", "gd", function()
      vim.cmd.vsplit()
      vim.lsp.buf.definition()
    end, { buffer = args.buf, desc = "Definition (vertical split)" })

    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if not client then
      return
    end

    -- Inlay hints: parameter names and inferred types drawn inline as virtual
    -- text. rust-analyzer is what makes this worth having; the capability
    -- check is what lets the servers that offer nothing simply opt out.
    if client:supports_method("textDocument/inlayHint") then
      vim.lsp.inlay_hint.enable(true, { bufnr = args.buf })
    end

    -- Highlight the other references to the symbol under the cursor once the
    -- cursor settles, and clear them the moment it moves. The delay is
    -- `updatetime`, set in init.lua. No highlight group is defined for this:
    -- core's LspReference* groups link through to Visual, so the marks take
    -- solarized8's selection colour and follow it if the scheme ever changes.
    if client:supports_method("textDocument/documentHighlight") then
      vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
        group = highlight,
        buffer = args.buf,
        callback = vim.lsp.buf.document_highlight,
      })

      vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
        group = highlight,
        buffer = args.buf,
        callback = vim.lsp.buf.clear_references,
      })
    end
  end,
})

-- Ask for inlay hints again whenever a server finishes a task.
--
-- vim.lsp.inlay_hint makes one request when hints are enabled for a buffer, and
-- afterwards only a didOpen or didChange retries it. rust-analyzer answers that
-- first request while it is still indexing, and answers it with an empty list.
-- It does then send workspace/inlayHint/refresh, which the client advertises
-- support for, but the requests that provoke -- still arriving mid-index --
-- come back as ContentModified errors, and on_inlayhint abandons the buffer on
-- any error at all rather than retrying.
--
-- The upshot is a race that the first buffer opened reliably loses, since it
-- attaches when the server is busiest: hints appear in every buffer opened
-- later, never in that one, and editing it is the only thing that brings them
-- back. Progress notifications are the signal that indexing has actually
-- settled, so a request made when one ends is the one that succeeds.
--
-- Asking blindly does not work, because vim.lsp.inlay_hint treats an empty
-- result as "clear the hints". Retrying into an unsettled server therefore
-- races: whichever answer lands last decides, and a late empty one wipes a good
-- one that already arrived. Measured across repeated cold starts, retrying on
-- every notification and coalescing the retries were both unreliable, in
-- opposite ways and for the same underlying reason.
--
-- So the server is asked privately first, through a handler of this module's
-- own, where an empty or errored answer costs nothing because Neovim never sees
-- it. Only once a probe comes back with hints is Neovim's own request re-armed,
-- and by then the server is demonstrably ready to answer it.
local function probe_hints(client, buf)
  if not vim.api.nvim_buf_is_loaded(buf) or not vim.lsp.inlay_hint.is_enabled({ bufnr = buf }) then
    return
  end

  client:request("textDocument/inlayHint", {
    textDocument = vim.lsp.util.make_text_document_params(buf),
    range = {
      start = { line = 0, character = 0 },
      ["end"] = { line = math.max(vim.api.nvim_buf_line_count(buf) - 1, 0), character = 0 },
    },
  }, function(err, result)
    if err or not result or #result == 0 then
      return
    end

    vim.lsp.inlay_hint.enable(true, { bufnr = buf })
  end, buf)
end

-- Progress notifications mark the points at which the server's answer may have
-- changed, which is when a probe is worth making.
vim.api.nvim_create_autocmd("LspProgress", {
  group = vim.api.nvim_create_augroup("chris.lsp.progress", { clear = true }),
  pattern = "end",
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if not client or not client:supports_method("textDocument/inlayHint") then
      return
    end

    for buf in pairs(client.attached_buffers or {}) do
      probe_hints(client, buf)
    end
  end,
})

-- A server can also settle after its last progress notification, leaving a
-- buffer that no probe will ever revisit. Idling covers that: the cursor coming
-- to rest is both a good moment to ask and one that only happens once the
-- editor is actually in use, by which point any server has long since finished
-- starting. Buffers that already have hints are skipped, so this costs nothing
-- in the ordinary case -- a file with genuinely no hints to show is the only
-- one that keeps being asked, one cheap request per pause.
vim.api.nvim_create_autocmd("CursorHold", {
  group = vim.api.nvim_create_augroup("chris.lsp.hints.idle", { clear = true }),
  callback = function(args)
    if #vim.lsp.inlay_hint.get({ bufnr = args.buf }) > 0 then
      return
    end

    for _, client in ipairs(vim.lsp.get_clients({ bufnr = args.buf, method = "textDocument/inlayHint" })) do
      probe_hints(client, args.buf)
    end
  end,
})

-- Without this, a server that detaches and reattaches -- an :LspRestart, or a
-- root directory that resolves differently after a file move -- would leave
-- its predecessor's autocommands in place and register a second copy on top.
vim.api.nvim_create_autocmd("LspDetach", {
  group = vim.api.nvim_create_augroup("chris.lsp.detach", { clear = true }),
  callback = function(args)
    vim.lsp.buf.clear_references()
    vim.api.nvim_clear_autocmds({ group = highlight, buffer = args.buf })
  end,
})
