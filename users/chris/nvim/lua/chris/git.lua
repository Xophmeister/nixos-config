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

  -- Signs are laid out left to right by descending priority, so this keeps
  -- git marks in the first gutter slot with diagnostics beside them, rather
  -- than being shunted right whenever a line also has a diagnostic.
  -- Diagnostic signs start at 10 and, under severity_sort, rise to 13 for
  -- errors; anything above that will do. It also means that when the gutter
  -- overflows, a diagnostic is dropped rather than the git mark.
  sign_priority = 20,

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

-- Conflict resolution in the conflicted file itself, rather than across the
-- four windows `git mergetool` opens by default; git.nix sets its layout to
-- the merged file alone for that reason. The plugin finds conflicted files by
-- asking git, and only looks when Neovim's working directory is the top of a
-- repository -- which is where mergetool starts it.
--
-- The default mappings stand. co, ct, cb and c0 shadow `c` followed by a
-- motion, but they are bound only to a buffer with conflicts in it, and are
-- taken away again once the last one is resolved. disable_diagnostics is left
-- off: the markers do upset language servers, but the plugin implements it
-- with vim.diagnostic.disable, which Neovim 0.12 no longer has at all.
require("git-conflict").setup()
