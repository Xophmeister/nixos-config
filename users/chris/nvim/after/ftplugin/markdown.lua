-- Prose behaves as wrapped display lines rather than long logical ones, so
-- that vertical motion moves by what is on screen.

vim.opt_local.foldenable = false

-- No automatic hard wrapping: the buffer wraps visually instead, so the
-- underlying line stays one paragraph.
vim.opt_local.formatoptions:remove({ "t", "c" })
vim.opt_local.wrap = true
vim.opt_local.linebreak = true
vim.opt_local.breakindent = true
vim.opt_local.breakindentopt = "list:-1"
vim.opt_local.formatlistpat = [[^\s*\d\+[.)]\s\+\|^\s*[-*+]\s\+]]

local undo = {}

local function map(mode, lhs, rhs, opts)
  vim.keymap.set(mode, lhs, rhs, vim.tbl_extend("force", { buffer = true }, opts or {}))

  for _, m in ipairs(type(mode) == "table" and mode or { mode }) do
    table.insert(undo, ("silent! %sunmap <buffer> %s"):format(m, lhs))
  end
end

-- A bare j or k moves by display line; with a count it moves by real line, so
-- that relative-number jumps and recorded macros still land where intended.
local function by_display(real, display)
  return function()
    return vim.v.count > 0 and real or display
  end
end

for lhs, pair in pairs({
  ["j"] = { "j", "gj" },
  ["k"] = { "k", "gk" },
  ["<Down>"] = { "j", "gj" },
  ["<Up>"] = { "k", "gk" },
}) do
  map({ "n", "x" }, lhs, by_display(pair[1], pair[2]), { expr = true })
end

-- Insert mode takes no count, so these are unconditional.
map("i", "<Down>", "<C-o>gj")
map("i", "<Up>", "<C-o>gk")

-- Line-extent motions, likewise by display line.
for lhs, rhs in pairs({
  ["<Home>"] = "g<Home>",
  ["<End>"] = "g<End>",
  ["0"] = "g0",
  ["^"] = "g^",
  ["$"] = "g$",
}) do
  map("n", lhs, rhs)
end

-- Hand back a clean buffer if the filetype changes underneath us.
local previous = vim.b.undo_ftplugin
vim.b.undo_ftplugin = (previous and previous ~= "" and previous .. " | " or "")
  .. table.concat(undo, " | ")
