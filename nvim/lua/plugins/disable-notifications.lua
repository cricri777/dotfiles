-- Noice only for the centered cmdline popup; notifications and messages stay off.
return {
	{
		"folke/noice.nvim",
		opts = {
			cmdline = { view = "cmdline_popup" },
			messages = { enabled = false },
			popupmenu = { enabled = false },
			notify = { enabled = false },
			lsp = {
				progress = { enabled = false },
				hover = { enabled = false },
				signature = { enabled = false },
			},
			presets = { command_palette = false },
		},
	},
	{ "rcarriga/nvim-notify", enabled = false },
	{
		"folke/snacks.nvim",
		opts = {
			notifier = { enabled = false },
		},
	},
}
