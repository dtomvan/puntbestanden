{ config, lib, pkgs, ... }: {
	options = {
	};
	config.programs.nixvim = {
		plugins.friendly-snippets.enable = true;
		plugins.nvim-snippets = {
			enable = true;
			settings = {
				friendly_snippets = true;
			};
		};
		plugins.cmp = {
			enable = true;
			settings.sources = [
				{ name = "nvim_lsp"; }
				{ name = "snippets"; }
				{ name = "path"; }
				{ name = "buffer"; }
			];
			settings.mapping = {
				"<C-Space>" = "cmp.mapping.complete()";
				"<C-d>" = "cmp.mapping.scroll_docs(-4)";
				"<C-e>" = "cmp.mapping.close()";
				"<C-f>" = "cmp.mapping.scroll_docs(4)";
				"<CR>" = "cmp.mapping.confirm({ select = true })";
				"<C-p>" = "cmp.mapping(cmp.mapping.select_prev_item(), {'i', 's'})";
				"<C-n>" = "cmp.mapping(cmp.mapping.select_next_item(), {'i', 's'})";
			};
		};
		keymaps = [
			{
				key = "<c-y>";
				action = "<cmd>lua vim.snippet.jump(1)<cr>";
				mode = "i";
			}
		];
	};
}
