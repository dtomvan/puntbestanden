{...}: {
  imports = [
    ./mini.nix
		./snacks.nix
    ./tex.nix
    ./flash.nix
    ./cmp.nix
  ];

	programs.nixvim.keymaps = [
					    {
		    action = "<cmd>Telescope find_files<cr>";
		    key = "<c-e>";
		  }
		  {
		    action = "<cmd>Telescope live_grep<cr>";
		    key = "<c-p>";
		  }
	];
  programs.nixvim.plugins = {
    telescope.enable = true;
		telescope.extensions.fzy-native.enable = true;
		telescope.extensions.fzy-native.settings = {
			override_file_sorter = true;
			override_generic_sorter = false;
		};
		# telescope.lazyLoad.settings.keys = [
		# 			    {
		#     __unkeyed-1 = "<cmd>Telescope find_files<cr>";
		#     __unkeyed-3 = "<c-e>";
		#   }
		#   {
		#     __unkeyed-1 = "<cmd>Telescope live_grep<cr>";
		#     __unkeyed-3 = "<c-p>";
		#   }
		# ];
    neo-tree.enable = true;
  };
}
