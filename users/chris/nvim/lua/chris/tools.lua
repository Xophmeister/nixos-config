-- Completion, navigation and Copilot.

-- Completion.
--
-- blink.cmp replaces the ALE-completion-plus-supertab arrangement. It manages
-- `completeopt` itself, so that is not set here. <Tab> and <S-Tab> walk the
-- menu, <CR> accepts, <C-space> opens it, and <C-e> dismisses.
require("blink.cmp").setup({
  keymap = { preset = "default" },

  sources = {
    default = { "lsp", "path", "snippets", "buffer" },
  },

  completion = {
    documentation = { auto_show = true, auto_show_delay_ms = 200 },
    ghost_text = { enabled = false },
  },

  signature = { enabled = true },
})

-- Copilot.
--
-- The standalone language server is used rather than the Node one: it is
-- packaged in nixpkgs and reached through the wrapper's PATH, whereas the
-- Node path would want a runtime this configuration does not otherwise need.
--
-- Suggestions are inline ghost text on <M-l>, deliberately clear of the
-- completion menu's keys. `ghost_text` is off in blink above for the same
-- reason -- two plugins drawing virtual text at the cursor is unreadable.
require("copilot").setup({
  server = {
    type = "binary",
    custom_server_filepath = "copilot-language-server",
  },

  suggestion = {
    enabled = true,
    auto_trigger = true,
    keymap = {
      accept = "<M-l>",
      next = "<M-]>",
      prev = "<M-[>",
      dismiss = "<C-]>",
    },
  },

  panel = { enabled = false },

  filetypes = {
    gitcommit = false,
    gitrebase = false,
    ["."] = false,
  },
})

-- Fuzzy finding.
local fzf = require("fzf-lua")

fzf.setup({ "default" })

local function find(fn, desc)
  return { fn, desc = desc }
end

for lhs, spec in pairs({
  ["<leader>ff"] = find(fzf.files, "Find files"),
  ["<leader>fg"] = find(fzf.live_grep, "Live grep"),
  ["<leader>fb"] = find(fzf.buffers, "Find buffers"),
  ["<leader>fh"] = find(fzf.helptags, "Find help"),
  ["<leader>fs"] = find(fzf.lsp_document_symbols, "Document symbols"),
  ["<leader>fS"] = find(fzf.lsp_workspace_symbols, "Workspace symbols"),
  ["<leader>fd"] = find(fzf.diagnostics_document, "Document diagnostics"),
  ["<leader>fr"] = find(fzf.resume, "Resume last search"),
}) do
  vim.keymap.set("n", lhs, spec[1], { desc = spec.desc })
end

-- Pending-keymap discovery.
local wk = require("which-key")

wk.setup({})

wk.add({
  { "<leader>f", group = "find" },
  { "<localleader>", group = "repl" },
})
