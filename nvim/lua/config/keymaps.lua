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
