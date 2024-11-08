{pkgs, lib, config, ...} : {
    options = with lib; {
        zsh.enable = mkEnableOption "install and configure zsh";
        zsh.omz.enable = mkEnableOption "install oh-my-zsh";
        zsh.omz.extra-plugins = mkOption {
            description = "extra oh-my-zsh plugins to enable";
            type = with types; listOf str;
            default = [ ];
        };
        zsh.atuin.enable = mkEnableOption "install atuin and configure with zsh";
    };

    config.home.packages = [ pkgs.zoxide ];
    config.programs.zsh = lib.mkIf config.zsh.enable {
        enable = true;
        autocd = true;
        autosuggestion.enable = true;
        syntaxHighlighting.enable = true;
        defaultKeymap = "viins";

        history = {
            size = 30000;
            save = 30000;
        };

        oh-my-zsh = lib.mkIf config.zsh.omz.enable {
            enable = true;
            theme = "clean";
            plugins = [
                "git"
                "mise"
                "zoxide"
            ] ++ config.zsh.omz.extra-plugins;
        };

        plugins = [
        {
            name = "zsh-vi-mode";
            src = pkgs.zsh-vi-mode.src;
        }
        ];

        initExtra = lib.mkIf config.zsh.atuin.enable ''
            eval "''$(${pkgs.atuin}/bin/atuin init zsh --disable-up-arrow)"
            '';
    };

}
