{ config, ... }:
{
  text.readme = {
    order = [
      "intro"
      "nixos_configs"
      "home_configs"
      "contents_rest"
      "dendritic"
      "hostnames"
      "autounattend"
      "community_autounattend"
      "localsend_rs"
    ];

    parts.intro =
      # markdown
      ''
        # Puntbestanden

        > Literally means "dotfiles" in Dutch: "punt" = "dot", "bestanden" = "files"

        What's in here:
      '';

    parts.contents_rest =
      # markdown
      ''

        - An unhinged Emacs config
        - A lot less lines of neovim lua config compared to my [previous attempt](https://github.com/dtomvan/.config/tree/main/neovim/.config/nvim)
      '';
  };

  perSystem.files.files = [
    {
      path_ = "README.md";
      drv = builtins.toFile "README.md" config.text.readme;
    }
  ];
}
