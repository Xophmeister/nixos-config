-- Language servers.
--
-- Neovim 0.11 moved LSP configuration into core: `vim.lsp.config` registers a
-- server and `vim.lsp.enable` starts it against matching buffers. nvim-lspconfig
-- is still here, but only as the community's collection of `lsp/*.lua` defaults
-- feeding that mechanism -- so the definitions below say nothing more than where
-- this setup differs from those defaults.

-- Completion capabilities are advertised once, for every server, rather than
-- being threaded through each definition.
vim.lsp.config("*", {
  capabilities = require("blink.cmp").get_lsp_capabilities({}, false),
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
-- Note that this server refuses to initialise without a chicken-doc
-- repository and exits 70 on the initialize request. The repository is
-- stateful -- built by chicken-doc-admin from the CHICKEN documentation --
-- so it is not present on a fresh machine and nothing here can conjure it.
-- Until one exists, Scheme has treesitter highlighting and Conjure but no
-- LSP. This was equally true before, but ALE swallowed the failure.
vim.lsp.config("chicken_lsp", {
  cmd = { "chicken-lsp-server", "--stdio" },
  filetypes = { "scheme" },
  root_dir = chicken_root,
})

-- clojure_lsp and tofu_ls are taken entirely from nvim-lspconfig: their
-- defaults already look for deps.edn/project.clj/build.boot and
-- .terraform/.git respectively, which is what the ALE configuration
-- was reproducing by hand.
vim.lsp.enable({
  "chicken_lsp",
  "clojure_lsp",
  "pylsp",
  "rust_analyzer",
  "tofu_ls",
})

-- Buffer-local mappings, applied as each server attaches.
--
-- Only `gd` is bound here, opening the definition in a vertical split as the
-- ALE mapping did. Rename, code action and references are deliberately left
-- to Neovim's own defaults -- grn, gra, grr and gri -- which a mapping on
-- `gr` would shadow, costing a timeout on every one of them.
vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("chris.lsp.attach", { clear = true }),
  callback = function(args)
    vim.keymap.set("n", "gd", function()
      vim.cmd.vsplit()
      vim.lsp.buf.definition()
    end, { buffer = args.buf, desc = "Definition (vertical split)" })
  end,
})
