-- Remove all notification popups (noice + snacks notifier + nvim-notify).
return {
	{ "folke/noice.nvim", enabled = false },
	{ "rcarriga/nvim-notify", enabled = false },
	{
		"folke/snacks.nvim",
		opts = {
			notifier = { enabled = false },
		},
	},
}
