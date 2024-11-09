{ config, pkgs, lib, ...}: {
	options.modules.coach-lsp.enable = lib.mkEnableOption "download coach-lsp and add to nvim";
	config.programs.nixvim.plugins.lsp.enabledServers = lib.optionals config.modules.coach-lsp.enable [
	{
		name = "coach-lsp";
		extraOptions = {
			cmd = "${pkgs.coach}/bin/coach-lsp";
			filetypes = ["coach"];
			autostart = true;
			 on_attach.__raw = ''
			  function(client, bufnr)
				${config.programs.nixvim.plugins.lsp.onAttach}
			  end
			'';
		};
	}
	];
}
