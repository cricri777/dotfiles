return {
  "nvim-neo-tree/neo-tree.nvim",
  opts = {
    window = {
      mappings = {
        ["y"] = {
          function(state)
            local name = state.tree:get_node().name
            vim.fn.setreg("+", name, "c")
            vim.notify("Copied to clipboard: " .. name)
          end,
          desc = "Copy File Name to Clipboard",
        },
        ["<C-y>"] = "copy_to_clipboard",
      },
    },
  },
}
