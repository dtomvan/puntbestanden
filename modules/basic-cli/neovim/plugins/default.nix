{...}: {
    imports = [
        ./mini.nix
		./tex.nix
		./flash.nix
		./cmp.nix
    ];

    programs.nixvim.plugins = {
        telescope.enable = true;
        neo-tree.enable = true;
    };
}
