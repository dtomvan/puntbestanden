# NixOS module for a graphical guest account with various generic home-manager
# stuffs set. Use with `profiles-graphical`.
{
  self,
  lib,
  inputs,
  flake-parts-lib,
  ...
}:
let
  # HACK: re-import a subset of my config so I can create a guest account with
  # just the sensible defaults I provide in my modules/community/ tree and not
  # my own shit
  communityModules =
    (flake-parts-lib.mkFlake { inherit inputs; } {
      imports = (import lib/_import-tree.nix lib ./community) ++ [
        inputs.flake-parts.flakeModules.modules
        self.flakeModules.flake-inputs
      ];
    }).modules;
in
{
  flake.modules.nixos.guest =
    {
      self',
      inputs',
      pkgs,
      ...
    }:
    {
      imports = [
        inputs.home-manager.nixosModules.default
      ];

      users.users.guest = {
        isNormalUser = true;
        createHome = true;
        password = "guest";
      };

      # create a writable init.lua that points to the home-manager generated init file for lazyvim.
      systemd.tmpfiles.rules = [
        "d /home/guest/.config/nvim/lua/config 0744 guest users -"
        "f /home/guest/.config/nvim/lua/config/plugins.lua 0644 guest users - return {}"
      ];

      # some modules depend on these. notable profiles-base
      home-manager.extraSpecialArgs = { inherit self' inputs'; };

      home-manager.backupFileExtension = "bak";

      home-manager.users.guest = {
        imports = builtins.attrValues {
          inherit (self.modules.homeManager)
            firefox-ubo-only
            terminals
            profiles-base
            ;
          inherit (communityModules.homeManager)
            lazyvim
            firefox
            git
            jujutsu
            ;
        };

        programs.firefox = {
          enable = true;
          package = pkgs.firefox-devedition;
          profiles.ubo-only = {
            id = lib.mkForce 0;
            isDefault = lib.mkForce true;
          };
        };

        nixpkgs.overlays = [ inputs.nur.overlays.default ];
        home.stateVersion = "26.11";
      };
    };
}
