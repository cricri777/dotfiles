return {
  "dmtrKovalenko/fff",
  build = function()
    require("fff.download").download_or_build_binary()
  end,
  lazy = false,
  opts = {
    base_path = vim.fn.getcwd(),
    prompt_vim_mode = true,
  },
}
