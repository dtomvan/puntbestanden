{config, ...}: {
    programs.nixvim.plugins.mini = {
        enable = true;
        modules = {
            ai = {};
            basics = {
                options = {
                    basic = true;
                    extra_ui = true;
                };
                mappings.windows = true;
                autocommands = {
                    basic = true;
                };
            };
            # use colorscheme from nix-colors with mini.base16. really seamlessly.
            base16.palette = builtins.mapAttrs (k: v: "#${v}") config.colorScheme.palette;
            bracketed = {};
            comment = {};
            completion = {};
            icons = {};
            indentscope = {};
            notify = {};
            sessions = {};
            starter = {};
            statusline = {};
            surround = {
                mappings = {
                    app = "ys";
                    delete = "ds";
                    find = "";
                    find_left = "";
                    highlight = "";
                    replace = "cs";
                    update_n_lines = "";
                    suffix_last = "";
                    suffix_next = "";
                };
                search_method = "cover_or_next";
            };
        };
        mockDevIcons = true;
    };
}
