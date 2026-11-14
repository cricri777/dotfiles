-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

-- Remove the empty [No Name] buffer that `nvim .` (or `nvim <dir>`) leaves behind.
-- neo-tree hijacks the directory buffer but leaves it listed, so it shows up as an
-- extra empty buffer after you open your first file. See LazyVim#7254 / neo-tree#828.
vim.api.nvim_create_autocmd("BufReadPost", {
  desc = "Drop the empty [No Name] buffer left by `nvim .`",
  callback = function(args)
    vim.schedule(function()
      for _, b in ipairs(vim.api.nvim_list_bufs()) do
        if
          b ~= args.buf
          and vim.bo[b].buflisted
          and vim.bo[b].buftype == ""
          and vim.api.nvim_buf_get_name(b) == ""
          and not vim.bo[b].modified
          and vim.api.nvim_buf_line_count(b) == 1
          and vim.api.nvim_buf_get_lines(b, 0, 1, false)[1] == ""
          and #vim.fn.win_findbuf(b) == 0
        then
          vim.api.nvim_buf_delete(b, {})
        end
      end
    end)
  end,
})

-- Disable LazyVim's default spell checking for text filetypes but keep line wrapping.
vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")
vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("wrap_text", { clear = true }),
  pattern = { "text", "plaintex", "typst", "gitcommit", "markdown" },
  callback = function()
    vim.opt_local.wrap = true
  end,
})
