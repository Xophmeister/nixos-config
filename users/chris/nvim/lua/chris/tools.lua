-- Completion, navigation and Copilot.

-- Completion.
--
-- blink.cmp replaces the ALE-completion-plus-supertab arrangement. It manages
-- `completeopt` itself, so that is not set here.
--
-- The `enter` preset accepts on <CR>, which is the whole reason for choosing
-- it over `default`. Selection moves on <C-p>/<C-n> or the arrow keys, and
-- <Tab>/<S-Tab> step through snippet placeholders rather than walking the
-- menu -- that is true of every preset but `super-tab`, where <Tab> accepts
-- instead. <C-space> opens the menu, <C-e> dismisses it. Note that `enter`
-- binds no <C-y>, so <CR> is the only key that accepts.
require("blink.cmp").setup({
  keymap = { preset = "enter" },

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

-- Hover.
--
-- Neovim already answers textDocument/hover on K, so this is here for the
-- pointer rather than the keyboard: it reads the position under the pointer
-- instead of the cursor, which core has no equivalent for. K is deliberately
-- left alone, so that pointing and asking stay separate.
local hover = require("hover")

-- Only the window's appearance is configured here. The provider list lives at
-- the open() call below, so that there is one place saying what the pointer
-- consults rather than a configured default and an override to keep in step.
hover.config({
  -- Matches the diagnostic float in init.lua rather than the plugin's own
  -- single-line default.
  preview_opts = { border = "rounded" },
})

-- Pointer hover, driven from here rather than by hover.nvim's own mouse().
--
-- That function opens a window wherever the pointer happens to be, and when no
-- provider answers, the plugin substitutes a literal "No result" -- so resting
-- over blank space, or in the padding past the end of a line, yields a popup
-- that says nothing. There is no option to suppress it. Its debounce also
-- re-reads the pointer only once its timer expires, so a timer armed over a
-- symbol still fires after the pointer has left one.
--
-- Both ends are therefore checked: when the event arrives, to decide whether to
-- arm the timer at all, and again when it expires, in case the pointer moved in
-- the meantime.
local POINTER_DELAY = 500

-- Returned when the pointer is over a floating window, which will be the popup
-- itself: that should be left alone rather than closed out from under the
-- pointer.
local FLOAT = {}

local function pointer_word()
  local pos = vim.fn.getmousepos()

  -- winid is zero away from any window, and line is zero over a statusline or
  -- a vertical separator.
  if pos.winid == 0 or pos.line == 0 then
    return nil
  end

  if vim.api.nvim_win_get_config(pos.winid).relative ~= "" then
    return FLOAT
  end

  local buf = vim.fn.winbufnr(pos.winid)
  if buf == -1 then
    return nil
  end

  -- Past the end of a line getmousepos reports a column one beyond the text,
  -- so this indexes an empty string and falls through -- as it does past the
  -- last line, where getbufline returns nothing at all.
  local text = vim.fn.getbufline(buf, pos.line)[1] or ""
  if not text:sub(pos.column, pos.column):match("[%w_]") then
    return nil
  end

  return { buf = buf, line = pos.line, column = pos.column }
end

local pointer_timer = assert(vim.uv.new_timer())

-- Which buffer the popup was opened against. hover.close() defaults to the
-- current buffer, which is the wrong one whenever the pointer is over a split
-- that does not have focus.
local shown_for --- @type integer?

local function close_pointer_hover()
  if shown_for then
    hover.close(shown_for)
    shown_for = nil
  end
end

vim.keymap.set("n", "<MouseMove>", function()
  pointer_timer:stop()

  local target = pointer_word()

  if target == FLOAT then
    return
  end

  if not target then
    close_pointer_hover()
    return
  end

  pointer_timer:start(
    POINTER_DELAY,
    0,
    vim.schedule_wrap(function()
      local now = pointer_word()
      if not now or now == FLOAT then
        return
      end

      close_pointer_hover()
      shown_for = now.buf

      hover.open({
        -- man is left out deliberately: it would fire for any word at all and
        -- shell out to do it, which is not what pointing at code should cost.
        providers = {
          "hover.providers.diagnostic",
          "hover.providers.lsp",
        },
        relative = "mouse",
        pos = { now.line, now.column },
        bufnr = now.buf,
      })
    end)
  )
end, { desc = "Hover (pointer)" })

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
