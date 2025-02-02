{
  config,
  pkgs,
  lib,
  nix-colors,
  nixpkgs,
  hostname ? "tom-pc",
  username ? "tomvd",
  ...
}: {
  imports = [
    ../../modules/basic-cli
    ../../modules/hyprland
    ../../modules/terminals

    ../../modules/nerd-fonts.nix
    ../../modules/ags.nix
    ../../modules/gtk.nix
    ../../modules/lorri.nix
    ../../modules/sowon.nix

		../../modules/jc141.nix

    ../../scripts/listapps.nix
  ];

  modules = {
    ags.enable = true;
    ags.use-nix-colors = true;

    terminals.enable = true;
    terminals.foot = {
      enable = true;
      default = true;
      font = {
        size = 14;
        family = "Afio";
      };
    };

    hyprland.enable = true;
    hyprland.use-nix-colors = true;
    nerd-fonts.enable = true;
    gtk.enable = true;

    lorri.enable = true;
    sowon = {
      enable = true;
      enablePenger = true;
    };
    # coach-lsp.enable = true;
    # coach-lsp.use-cached = true;
    neovim.lsp.extraLspServers = {
      rust_analyzer = {
        enable = true;
        installCargo = true;
        installRustc = true;
      };
      nixd.enable = true;
      # set the nixpkgs to the flake input so nixd will hopefully search through the nixpkgs I am already using
      nixd.package = pkgs.symlinkJoin {
        name = "nixd";
        paths = [pkgs.nixd];
        buildInputs = [pkgs.makeWrapper];
        postBuild = ''
          wrapProgram $out/bin/nixd \
          --set "NIX_PATH" "nixpkgs=${nixpkgs}"
        '';
      };
      nixd.settings.formatting.command = [(lib.getExe pkgs.alejandra)];
      nixd.settings.options = let
        link-to-flake = config.lib.file.mkOutOfStoreSymlink ../../flake.nix;
        flake = ''(builtins.getFlake "${link-to-flake}")'';
      in {
        # set the path to the current nixos and home-manager configurations
        nixos.expr = ''${flake}.nixosConfigurations.${hostname}.options'';
        home-manager.expr = ''${flake}.homeConfigurations."${username}@${hostname}".options'';
      };
    };
  };

  home.username = username;
  home.homeDirectory = "/home/${username}";
  home.stateVersion = "24.05";

  colorScheme = nix-colors.colorSchemes.catppuccin-mocha;

  news.display = "silent";
  news.entries = lib.mkForce [];

  home.packages = with pkgs; [
    ripdrag
    file
    # cosmic-files
    afio-font
    (pkgs.writers.writeBashBin "nix-run4" ''
      nix run "$FLAKE#pkgs.$@"
    '')
  ];

  xdg.mimeApps = {
    enable = true;
    # defaultApplications."inode/directory" = ["cosmic-files.desktop"];
    defaultApplications."application/pdf" = ["zathura.desktop"];
  };

  programs.home-manager.enable = true;
}
# vim:sw=2 ts=2 sts=2

