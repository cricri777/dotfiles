-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- fff.nvim as the picker (overrides LazyVim/snacks picker defaults).
-- Deferred one tick so it wins regardless of VeryLazy handler/plugin load order.
vim.schedule(function()
  local function fff(fn)
    return function()
      require("fff")[fn]()
    end
  end

  vim.keymap.set("n", "<leader><space>", fff("find_files"), { desc = "Find Files (fff)" })
  vim.keymap.set("n", "<leader>ff", fff("find_files"), { desc = "Find Files (fff)" })
  vim.keymap.set("n", "<leader>/", fff("live_grep"), { desc = "Grep (fff)" })
  vim.keymap.set("n", "<leader>sg", fff("live_grep"), { desc = "Grep (fff)" })
  vim.keymap.set({ "n", "x" }, "<leader>sw", fff("live_grep_under_cursor"), { desc = "Grep Word/Selection (fff)" })
  vim.keymap.set("n", "<leader>fz", function()
    require("fff").live_grep({ grep = { modes = { "fuzzy", "plain" } } })
  end, { desc = "Fuzzy Grep (fff)" })
end)

-- Alt+M: expand NeoTree to take the whole screen, or restore its original width.
-- It never closes the tree (use <leader>e for that). If NeoTree is hidden, it is shown first.
local neotree_expanded = false
local neotree_base_width = nil

local function neotree_win()
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    if vim.bo[vim.api.nvim_win_get_buf(win)].filetype == "neo-tree" then
      return win
    end
  end
end

vim.keymap.set("n", "<M-m>", function()
  local win = neotree_win()
  if not win then
    vim.cmd("Neotree show")
    neotree_expanded = false
    return
  end

  if neotree_expanded then
    vim.api.nvim_win_set_width(win, neotree_base_width or 40)
    neotree_expanded = false
  else
    neotree_base_width = vim.api.nvim_win_get_width(win)
    vim.api.nvim_win_set_width(win, vim.o.columns)
    neotree_expanded = true
  end
end, { desc = "Toggle NeoTree width (expand / restore)" })

-- Terminal mode: a quick double <Esc> is the way to go from insert to normal mode.
-- The default <C-\><C-n> is disabled (mapped to <Nop>) so it no longer works.
-- (Snacks terminals have their own 200ms buffer-local double <Esc>, which takes
-- precedence; this makes it work in plain `:terminal` buffers too.)
vim.keymap.set("t", "<C-\\><C-n>", "<Nop>", { desc = "Disabled (use <Esc><Esc>)" })
vim.keymap.set("t", "<Esc><Esc>", [[<C-\><C-n>]], { desc = "Terminal: exit to normal mode" })

-- Alt+T: open / focus a terminal in a horizontal split at the bottom, small (~20% of the
-- screen height) so the code window keeps most of the space.
--   * a terminal window is visible in this tab -> focus it and resize it
--   * a terminal buffer exists but is hidden   -> reopen it in a bottom split
--   * otherwise                                -> open a new terminal in a bottom split
-- Pressing it again from inside the terminal just re-applies the size.
-- Side-by-side (vertical) terminals get ~40% of the width instead; floating ones are left alone.
local TERM_HEIGHT_RATIO = 0.20
local TERM_WIDTH_RATIO = 0.40

local function is_term_buf(buf)
  return vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].buftype == "terminal"
end

local function size_term_win(win)
  if vim.api.nvim_win_get_config(win).relative ~= "" then
    return
  end
  if vim.api.nvim_win_get_width(win) >= vim.o.columns then
    vim.api.nvim_win_set_height(win, math.max(3, math.floor(vim.o.lines * TERM_HEIGHT_RATIO)))
  else
    vim.api.nvim_win_set_width(win, math.floor(vim.o.columns * TERM_WIDTH_RATIO))
  end
end

vim.keymap.set({ "n", "t" }, "<M-t>", function()
  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    if is_term_buf(vim.api.nvim_win_get_buf(win)) and vim.api.nvim_win_get_config(win).relative == "" then
      vim.api.nvim_set_current_win(win)
      size_term_win(win)
      vim.cmd("startinsert")
      return
    end
  end

  local hidden
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if is_term_buf(buf) and vim.fn.bufwinid(buf) == -1 then
      hidden = buf
      break
    end
  end

  vim.cmd("botright " .. math.max(3, math.floor(vim.o.lines * TERM_HEIGHT_RATIO)) .. "split")
  if hidden then
    vim.api.nvim_win_set_buf(0, hidden)
  else
    vim.cmd("terminal")
  end
  vim.cmd("startinsert")
end, { desc = "Terminal: open / focus bottom split (small)" })
