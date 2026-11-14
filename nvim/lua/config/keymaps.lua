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
