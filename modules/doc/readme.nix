{ config, ... }:
{
  text.readme = {
    order = [
      "intro"
      "nixos_configs"
      "home_configs"
      "contents_rest"
      "hub"
      "disko_install"
      "dendritic"
      "hostnames"
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

  perSystem.files."README.md" = builtins.toFile "README.md" config.text.readme;
}
