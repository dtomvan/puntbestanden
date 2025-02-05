{config, pkgs, ... }: {
	config.home.packages = with pkgs; [lazygit];
	config.programs.nixvim.keymaps = [
		{
			key = "<space>lg";
			action = "<cmd>lua require('snacks').lazygit()<cr>";
		}
	];
	config.programs.nixvim.plugins.snacks = {
		enable = true;
		settings = {
			lazygit = {
				configure = true;
			};
  bigfile = {
    enabled = true;
  };
  quickfile = {
    enabled = true;
  };
  statuscolumn = {
    enabled = true;
  };
};
	};
}
