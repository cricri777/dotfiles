return {
  "nvim-neo-tree/neo-tree.nvim",
  opts = {
    window = {
      mappings = {
        ["y"] = {
          function(state)
            local name = state.tree:get_node().name
            vim.fn.setreg("+", name, "c")
            vim.fn.setreg("0", name, "c")
            vim.notify("Copied to clipboard and register 0: " .. name)
          end,
          desc = "Copy File Name to Clipboard and Register 0",
        },
        ["<C-y>"] = "copy_to_clipboard",
        -- Free z/Z so native zz/zt/zb scroll the tree; fold-style keys replace them.
        ["z"] = "none",
        ["Z"] = "none",
        ["zM"] = "close_all_nodes",
        ["zR"] = "expand_all_nodes",
      },
    },
  },
}
