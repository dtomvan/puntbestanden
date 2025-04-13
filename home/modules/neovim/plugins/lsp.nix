{
  pkgs,
  config,
  lib,
  ...
}: let
  cfg = config.modules.neovim;
in {
  programs.nixvim.plugins.lsp = lib.mkIf cfg.lsp.enable {
    enable = true;
    inlayHints = true;
    servers =
      {
        lua_ls.enable = true;
      }
      // cfg.lsp.extraLspServers
      // lib.optionalAttrs cfg.lsp.nixd.enable {
        rust_analyzer = {
          enable = true;
          installCargo = true;
          installRustc = true;
        };
      }
      // lib.optionalAttrs cfg.lsp.rust_analyzer.enable {
        nixd.enable = true;
        # set the nixpkgs to the flake input so nixd will hopefully search through the nixpkgs I am already using
        # nixd.package = pkgs.symlinkJoin {
        #   name = "nixd";
        #   paths = [pkgs.nixd];
        #   buildInputs = [pkgs.makeWrapper];
          # postBuild = ''
          #   wrapProgram $out/bin/nixd \
          #   --set "NIX_PATH" "nixpkgs=${nixpkgs}"
          # '';
        # };
        nixd.settings.formatting.command = [(lib.getExe pkgs.alejandra)];
        # nixd.settings.options = let
        #   link-to-flake = config.lib.file.mkOutOfStoreSymlink ../../flake.nix;
        #   flake = ''(builtins.getFlake "${link-to-flake}")'';
        # in {
          # set the path to the current nixos and home-manager configurations
          # nixos.expr = ''${flake}.nixosConfigurations.${hostname}.options'';
          # home-manager.expr = ''${flake}.homeConfigurations."${username}@${hostname}".options'';
        # };
      };
  };
}
