-- Configures syntax parsing and indentation detection.

return {
	-- NOTE: Plugins can be added with a link (or for a github repo: 'owner/repo' link).
	"NMAC427/guess-indent.nvim", -- Detect tabstop and shiftwidth automatically
	{ -- Highlight, edit, and navigate code
		-- This config for nvim-treesitter works with neovim 0.12.0 or later only.
		-- Tested on neovim 0.12.4
		"nvim-treesitter/nvim-treesitter",
		branch = "main",
		lazy = false,
		build = ":TSUpdate",
		config = function()
			local treesitter = require("nvim-treesitter")
			local ensure_installed = {
				"bash",
				"c",
				"diff",
				"html",
				"lua",
				"luadoc",
				"markdown",
				"markdown_inline",
				"query",
				"vim",
				"vimdoc",
			}

			local available = {}
			for _, lang in ipairs(treesitter.get_available()) do
				available[lang] = true
			end

			local function has_tree_sitter_cli()
				if vim.fn.executable("tree-sitter") ~= 1 then
					return false
				end

				local version = vim.version.parse(vim.fn.system({ "tree-sitter", "--version" }))
				return version ~= nil and vim.version.ge(version, { 0, 26, 1 })
			end

			local function configure_buffer(buf, filetype)
				local lang = vim.treesitter.language.get_lang(filetype) or filetype
				local function start()
					if not vim.api.nvim_buf_is_valid(buf) or vim.bo[buf].filetype ~= filetype then
						return
					end
					local ok = pcall(vim.treesitter.start, buf, lang)
					-- Keep Ruby's built-in indentation from neovim, as in the original Kickstart configuration.
					if ok and lang ~= "ruby" then
						vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
					end
				end

				if vim.treesitter.language.add(lang) then
					start()
				elseif available[lang] and has_tree_sitter_cli() then
					treesitter.install({ lang }):await(function(err, success)
						if not err and success and vim.treesitter.language.add(lang) then
							start()
						end
					end)
				end
			end

			local function install_parsers()
				if not has_tree_sitter_cli() then
					return
				end

				treesitter.install(ensure_installed)
				for _, buf in ipairs(vim.api.nvim_list_bufs()) do
					if vim.api.nvim_buf_is_loaded(buf) and vim.bo[buf].filetype ~= "" then
						configure_buffer(buf, vim.bo[buf].filetype)
					end
				end
			end

			vim.api.nvim_create_autocmd("FileType", {
				pattern = "*",
				callback = function(args)
					configure_buffer(args.buf, args.match)
				end,
			})

			-- Mason installs tree-sitter-cli asynchronously on a fresh setup.
			vim.api.nvim_create_autocmd("User", {
				pattern = "MasonToolsUpdateCompleted",
				callback = install_parsers,
			})

			install_parsers()
		end,
	},
	--{
	--  'sphamba/smear-cursor.nvim',

	--  opts = {
	--    smear_between_buffers = true,
	--    smear_between_neighbor_lines = true,
	--    scroll_buffer_space = true,
	--    legacy_computing_symbols_support = false,
	--    smear_insert_mode = true,
	--  },
	--},
}

-- vim: ts=2 sts=2 sw=2 et
