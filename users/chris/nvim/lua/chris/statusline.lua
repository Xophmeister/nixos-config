-- vim-airline's solarized theme, as a lualine one.
--
-- lualine ships a solarized_dark theme, but it paints the middle section
-- base1 (#93a1a1) -- a pale slab that reads as washed out against everything
-- else. The palette below is airline's instead, section for section, taken
-- from its solarized.vim with the defaults this configuration ran under:
-- neither g:solarized_base16 nor airline_solarized_dark_text was set, so the
-- canonical Solarized values apply rather than the base16 remapping.
--
-- The mode block is deliberately grey in normal mode and takes its colour
-- from the mode instead -- yellow inserting, magenta selecting, red
-- replacing.

local base03 = "#002b36"
local base02 = "#073642"
local base01 = "#586e75"
local base00 = "#657b83"
local base0 = "#839496"
local base1 = "#93a1a1"
local base2 = "#eee8d5"
local base3 = "#fdf6e3"

local yellow = "#b58900"
local magenta = "#d33682"
local red = "#dc322f"

return {
  -- airline N1, N2, N3
  normal = {
    a = { fg = base3, bg = base1, gui = "bold" },
    b = { fg = base2, bg = base00 },
    c = { fg = base01, bg = base02 },
  },

  -- airline I1, V1, R1. Only the mode block changes; the sections behind it
  -- are inherited from `normal`.
  insert = { a = { fg = base3, bg = yellow, gui = "bold" } },
  visual = { a = { fg = base3, bg = magenta, gui = "bold" } },

  -- Not bold, matching airline's R1.
  replace = { a = { fg = base3, bg = red } },

  -- airline leaves the command palette at the normal colours unless
  -- airline_solarized_enable_command_color is set, which it was not.
  command = { a = { fg = base3, bg = base1, gui = "bold" } },

  -- airline IA, for the window that does not have focus.
  inactive = {
    a = { fg = base02, bg = base00 },
    b = { fg = base02, bg = base00 },
    c = { fg = base0, bg = base02 },
  },
}
