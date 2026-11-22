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

-- Alt+T: open a terminal in a bottom split under the main editor window (not under the file tree).
-- Pressing it again toggles that terminal between ~20% of the screen height and full height.
local TERM_HEIGHT_RATIO = 0.20

local function is_floating(win)
  return vim.api.nvim_win_get_config(win).relative ~= ""
end

local function buftype(win)
  return vim.bo[vim.api.nvim_win_get_buf(win)].buftype
end

local function small_height()
  return math.max(3, math.floor(vim.o.lines * TERM_HEIGHT_RATIO))
end

local function find_term_win()
  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    if not is_floating(win) and buftype(win) == "terminal" then
      return win
    end
  end
end

-- The current window if it is a normal file window, else the widest non-terminal one.
local function editor_win()
  local cur = vim.api.nvim_get_current_win()
  if buftype(cur) == "" then
    return cur
  end
  local best
  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    if not is_floating(win) and buftype(win) ~= "terminal"
      and (not best or vim.api.nvim_win_get_width(win) > vim.api.nvim_win_get_width(best)) then
      best = win
    end
  end
  return best or cur
end

vim.keymap.set({ "n", "t" }, "<M-t>", function()
  local win = find_term_win()
  if win then
    local small = small_height()
    local big = vim.api.nvim_win_get_height(win) > small + 1
    vim.api.nvim_win_set_height(win, big and small or vim.o.lines)
    vim.api.nvim_set_current_win(win)
    return
  end

  local hidden
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].buftype == "terminal" and vim.fn.bufwinid(buf) == -1 then
      hidden = buf
      break
    end
  end

  vim.api.nvim_set_current_win(editor_win())
  vim.cmd("belowright " .. small_height() .. "split")
  if hidden then
    vim.api.nvim_win_set_buf(0, hidden)
  else
    vim.cmd("terminal")
    vim.bo.bufhidden = "wipe" -- closing the window also deletes the terminal buffer
  end
end, { desc = "Terminal: open under editor / toggle 20% <-> full" })
