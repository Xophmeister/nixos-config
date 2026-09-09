-- Neovim configuration.
--
-- The shape of this tree mirrors the Vim setup it replaces: this file holds
-- what .vimrc held -- options, mappings, filetype detection -- and
-- after/ftplugin/ holds per-filetype settings. What ALE used to do alone is
-- three separate concerns here, one module each under lua/chris/: language
-- servers, formatters and linters.
--
-- Non-ASCII characters appear in `listchars` and the diagnostic signs below.
-- Those are glyphs to be rendered rather than identifiers, so they are the
-- one place where the 7-bit rule does not apply.

-- Leaders are captured by plugins at the moment they define a mapping, so
-- they must be set before anything is required.
vim.g.mapleader = " "
vim.g.maplocalleader = ","

-- Appearance
vim.o.termguicolors = true
vim.o.background = "dark"
vim.o.number = true
vim.o.cursorline = true
vim.o.scrolloff = 2
vim.o.splitright = true
vim.o.showcmd = true

-- A two-window statusline rather than Neovim's global default, matching the
-- airline layout this replaces. lualine is told the same in ui.lua.
vim.o.laststatus = 2

-- Show the tabline only once a second tab exists. This is the native
-- equivalent of airline's tab_min_count = 2 with buffers hidden.
vim.o.showtabline = 1

-- Text width and wrapping
vim.o.wrap = false
vim.o.textwidth = 72
vim.o.colorcolumn = "+1"
vim.o.formatoptions = "croqlj"

-- Indentation. Two spaces, expanded, everywhere except where an ftplugin
-- says otherwise.
vim.o.expandtab = true
vim.o.shiftwidth = 2
vim.o.tabstop = 2
vim.o.softtabstop = 2
vim.o.autoindent = true
vim.o.smartindent = true

-- Whitespace made visible: a tab renders as an arrow plus padding, trailing
-- spaces as a middle dot.
vim.o.list = true
vim.opt.listchars = { tab = "→ ", trail = "·" }

-- Searching
vim.o.hlsearch = true
vim.o.incsearch = true

-- Spelling
vim.o.spell = true
vim.o.spelllang = "en_gb"

-- Modelines are trusted here; Neovim disables them by default on the
-- grounds that they are executable content in a data file.
vim.o.modeline = true
vim.o.modelines = 5

vim.o.mouse = "a"

-- Restore the blinking cursor.
--
-- Ghostty is configured for a blinking block, and terminal Vim simply left
-- the cursor alone, so that setting held. Neovim instead drives the cursor
-- itself: it maps each `guicursor` entry to a DECSCUSR code, and the shapes
-- it ships by default carry no blink parameters, which selects the steady
-- variant of each code and overrides the terminal.
--
-- Only the blink timings are added below; the shapes are Neovim's own, so
-- the cursor still reports the mode -- a block in normal, a bar in insert,
-- an underline when replacing.
vim.o.guicursor = table.concat({
  "n-v-c-sm:block-blinkwait700-blinkon500-blinkoff300",
  "i-ci-ve:ver25-blinkwait700-blinkon500-blinkoff300",
  "r-cr-o:hor20-blinkwait700-blinkon500-blinkoff300",
}, ",")

-- Persistent undo. Neovim's default undodir is under stdpath("state"),
-- which is where this belongs, so only the switch itself is set.
vim.o.undofile = true
vim.o.undolevels = 1000
vim.o.undoreload = 10000

-- Share the system clipboard for unprefixed yanks and puts. Prepending
-- rather than assigning keeps whatever Neovim already had in the list.
vim.opt.clipboard:prepend({ "unnamed", "unnamedplus" })

-- Filetypes Neovim does not detect on its own.
--
-- *.tofu previously lived in an ftplugin, which meant its autocommand was
-- only registered once a Terraform buffer had already been opened -- so the
-- first .tofu file of a session was never recognised. Declaring it here runs
-- the detection at startup instead.
vim.filetype.add({
  extension = {
    scm = "scheme",
    ss = "scheme",
    sld = "scheme",
    egg = "scheme",
    tofu = "terraform",
  },
})

-- Diagnostics. The signs carry over from the ALE configuration; the rest is
-- Neovim's own diagnostic framework, which ALE used to shadow.
vim.diagnostic.config({
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = "🔥",
      [vim.diagnostic.severity.WARN] = "⚠️",
      [vim.diagnostic.severity.INFO] = "ℹ️",
      [vim.diagnostic.severity.HINT] = "💁‍♂️",
    },
  },
  virtual_text = true,
  severity_sort = true,
  float = { border = "rounded", source = true },
})

require("chris.ui")
require("chris.lsp")
require("chris.edit")
require("chris.tools")
require("chris.lisp")
