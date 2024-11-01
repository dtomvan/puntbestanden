{...}: {
    imports = [
        ./mini.nix
    ];

    programs.nixvim.plugins = {
        telescope.enable = true;
        neo-tree.enable = true;
    };
}
