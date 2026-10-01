-- Defines autocommands that do not depend on a specific plugin.

-- [[ Basic Autocommands ]]
--  See `:help lua-guide-autocommands`

-- Highlight when yanking (copying) text
--  Try it with `yap` in normal mode
--  See `:help vim.hl.on_yank()`
vim.api.nvim_create_autocmd("TextYankPost", {
	desc = "Highlight when yanking (copying) text",
	group = vim.api.nvim_create_augroup("kickstart-highlight-yank", { clear = true }),
	callback = function()
		vim.hl.on_yank()
	end,
})

vim.api.nvim_create_autocmd("FileType", {
	desc = "Indent Go files with 4-column tabs",
	pattern = "go",
	group = vim.api.nvim_create_augroup("go-indentation", { clear = true }),
	callback = function()
		vim.opt_local.expandtab = false
		vim.opt_local.tabstop = 4
		vim.opt_local.shiftwidth = 0
		vim.opt_local.softtabstop = 0
		vim.opt_local.smarttab = true
	end,
})

vim.api.nvim_create_autocmd("FileType", {
	desc = "Wrap long lines at word boundaries in Markdown files",
	pattern = "markdown",
	group = vim.api.nvim_create_augroup("markdown-linebreak", { clear = true }),
	callback = function()
		vim.opt_local.linebreak = true
	end,
})

-- vim: ts=2 sts=2 sw=2 et
