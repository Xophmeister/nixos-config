-- The glyphs drawn in the gutter and the statusline, in one place.
--
-- Diagnostics are rendered twice over -- as signs by vim.diagnostic and as
-- counts by lualine -- and gitsigns draws a third set beside them. Naming them
-- here is what keeps those copies from drifting apart.
--
-- Written as \u escapes rather than literal codepoints, so this file stays
-- 7-bit ASCII while still producing the glyphs. The diagnostic set needs a
-- Nerd Font to render; the git set is ordinary box drawing, because a gutter
-- mark reads better as a bar than as a picture.
return {
  diagnostics = {
    error = "\u{f057}", -- nf-fa-times_circle
    warn = "\u{f071}", -- nf-fa-exclamation_triangle
    info = "\u{f05a}", -- nf-fa-info_circle
    hint = "\u{f0eb}", -- nf-fa-lightbulb_o
  },

  git = {
    add = "\u{2503}", -- heavy vertical
    change = "\u{2503}",
    delete = "\u{2581}", -- lower one eighth block
    topdelete = "\u{2594}", -- upper one eighth block
    changedelete = "~",
    untracked = "\u{2506}", -- light triple dash vertical
  },
}
