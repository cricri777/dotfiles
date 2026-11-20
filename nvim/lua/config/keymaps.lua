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

-- Alt+T: resize the terminal split so it is a bit smaller than the code window.
-- Stacked below the code (horizontal split) -> ~35% of the screen height.
-- Side by side with the code (vertical split) -> ~40% of the screen width.
-- Works from normal and terminal mode, only on terminal windows.
local TERM_HEIGHT_RATIO = 0.35
local TERM_WIDTH_RATIO = 0.40

vim.keymap.set({ "n", "t" }, "<M-t>", function()
  local win = vim.api.nvim_get_current_win()
  if vim.bo[vim.api.nvim_win_get_buf(win)].buftype ~= "terminal" then
    return
  end
  if vim.api.nvim_win_get_config(win).relative ~= "" then
    return -- floating terminal: nothing to resize
  end
  if vim.api.nvim_win_get_width(win) >= vim.o.columns then
    vim.api.nvim_win_set_height(win, math.floor(vim.o.lines * TERM_HEIGHT_RATIO))
  else
    vim.api.nvim_win_set_width(win, math.floor(vim.o.columns * TERM_WIDTH_RATIO))
  end
end, { desc = "Resize terminal split (smaller than code window)" })
