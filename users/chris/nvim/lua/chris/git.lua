-- Git decoration: which lines have changed, and what can be done about them
-- without leaving the buffer.
--
-- lualine's `diff` section already counts changes, through its own git_diff
-- backend, so this is not what puts those numbers on the statusline. What it
-- adds is per-line marks in the gutter and the hunk operations beside them.

local gitsigns = require("gitsigns")
local glyphs = require("chris.glyphs")

gitsigns.setup({
  -- Named explicitly rather than left to the defaults, so that every glyph
  -- this configuration draws is accounted for in one file. These happen to
  -- match gitsigns' own defaults.
  signs = {
    add = { text = glyphs.git.add },
    change = { text = glyphs.git.change },
    delete = { text = glyphs.git.delete },
    topdelete = { text = glyphs.git.topdelete },
    changedelete = { text = glyphs.git.changedelete },
    untracked = { text = glyphs.git.untracked },
  },

  -- Mappings are bound per buffer as gitsigns attaches, so they exist only
  -- where there is a repository to act on. A file outside one keeps ]c and
  -- [c for whatever else wants them.
  on_attach = function(buf)
    local function map(lhs, rhs, desc, opts)
      vim.keymap.set(
        "n",
        lhs,
        rhs,
        vim.tbl_extend("force", { buffer = buf, desc = desc }, opts or {})
      )
    end

    -- ]c and [c are Vim's own jumps between diff hunks, which do nothing
    -- outside a diff. Taking them here keeps the motion in the fingers either
    -- way: in a real diff the builtin is returned untouched, otherwise the
    -- jump is gitsigns'. The scheduling is gitsigns' own advice -- navigating
    -- from inside an expression mapping is not allowed.
    map("]c", function()
      if vim.wo.diff then
        return "]c"
      end
      vim.schedule(function()
        gitsigns.nav_hunk("next")
      end)
      return "<Ignore>"
    end, "Next hunk", { expr = true })

    map("[c", function()
      if vim.wo.diff then
        return "[c"
      end
      vim.schedule(function()
        gitsigns.nav_hunk("prev")
      end)
      return "<Ignore>"
    end, "Previous hunk", { expr = true })

    -- The four operations worth a key. Staging and resetting are the point of
    -- the plugin; preview and blame answer "what did I change here" and "who
    -- wrote this" without a trip to the shell.
    map("<leader>hs", gitsigns.stage_hunk, "Stage hunk")
    map("<leader>hr", gitsigns.reset_hunk, "Reset hunk")
    map("<leader>hp", gitsigns.preview_hunk, "Preview hunk")
    map("<leader>hb", function()
      gitsigns.blame_line({ full = true })
    end, "Blame line")
  end,
})
