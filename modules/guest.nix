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
      # community tree requires flake-file
      imports = [
        (inputs.import-tree ./community)
        inputs.flake-parts.flakeModules.modules
        inputs.flake-file.flakeModules.default
      ];
    }).modules;
in
{
  flake.modules.nixos.guest =
    { pkgs, ... }:
    let
      inherit (pkgs.stdenv.hostPlatform) system;
    in
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
        "f /home/guest/.config/nvim/init.lua 0644 guest users - require(\"config.lazy\")"
        "f /home/guest/.config/nvim/lua/config/plugins.lua 0644 guest users - return {}"
      ];

      home-manager.users.guest = {
        imports =
          (with self.modules.homeManager; [
            firefox-ubo-only
            webapps
            terminals
            profiles-base
          ])
          ++ (with communityModules.homeManager; [
            lazyvim
            firefox
            git
            jujutsu
          ]);

        programs.firefox = {
          enable = true;
          package = self.legacyPackages.${system}.makeFakeFirefox pkgs.firefox-devedition {
            args = "-P ubo-only";
          };
          profiles.ubo-only = {
            id = lib.mkForce 0;
            isDefault = lib.mkForce true;
          };
        };

        nixpkgs.overlays = [ inputs.nur.overlays.default ];
        home.stateVersion = "25.11";
      };
    };
}
