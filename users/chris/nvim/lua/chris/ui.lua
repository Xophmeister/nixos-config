-- Appearance: colours, syntax, statusline and the symbol outline.

-- Solarized is applied before anything else so that later plugins pick up
-- its highlight groups as they initialise.
vim.cmd.colorscheme("solarized8")

-- Signs share the buffer's background rather than sitting in a differently
-- coloured gutter that shifts as diagnostics come and go.
vim.cmd("highlight clear SignColumn")

-- Treesitter.
--
-- Grammars are supplied by Nix, so nothing here installs or updates them.
-- This is nvim-treesitter's `main` branch, which no longer has the
-- `configs.setup{ highlight = ... }` entry point that most guides still show:
-- highlighting is started per buffer instead.
--
-- Indentation is deliberately left to Neovim's own rules. Treesitter's
-- indentexpr is still experimental, and for Clojure and Scheme it would
-- fight parinfer and vim-sexp over the same buffers.
vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("chris.treesitter", { clear = true }),
  callback = function(args)
    pcall(vim.treesitter.start, args.buf)
  end,
})

-- Rainbow parentheses, now driven by the treesitter parse tree rather than
-- by regex. It only acts where a grammar and delimiter queries exist, which
-- covers the Lisps this matters for.
require("rainbow-delimiters.setup").setup({})

-- Statusline.
--
-- The section layout reproduces the airline configuration: branch and
-- diagnostics shown, whitespace warnings not. `globalstatus` is off to match
-- laststatus = 2, and the tabline shows tabs rather than buffers.
require("lualine").setup({
  options = {
    theme = "solarized_dark",
    globalstatus = false,
    icons_enabled = true,

    -- lualine sets showtabline itself, to 2 by default, which would pin the
    -- tabline open. This hands the decision back to the value init.lua sets.
    always_show_tabline = false,
  },
  sections = {
    lualine_a = { "mode" },
    lualine_b = { "branch", "diff" },
    lualine_c = { "filename" },
    lualine_x = { "diagnostics", "encoding", "fileformat", "filetype" },
    lualine_y = { "progress" },
    lualine_z = { "location" },
  },
  tabline = {
    lualine_a = { "tabs" },
  },
  extensions = { "aerial", "fzf", "quickfix" },
})

-- Symbol outline, in place of tagbar. Backed by the language server where one
-- is attached and by treesitter otherwise, so it no longer needs ctags or a
-- tags file.
require("aerial").setup({
  backends = { "lsp", "treesitter", "markdown", "man" },
  layout = { default_direction = "right" },
})

vim.keymap.set("n", "<leader>o", "<cmd>AerialToggle!<CR>", { desc = "Toggle symbol outline" })
