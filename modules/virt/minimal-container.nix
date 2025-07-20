{
  inputs,
  config,
  ...
}:
let
  system = "x86_64-linux";
in
{
  flake.nixosConfigurations.minimal-container = inputs.nixpkgs.lib.nixosSystem {
    modules = with config.flake.modules.nixos; [
      sops
      services-localsend-rs
      users-tomvd
      (
        { pkgs, ... }:
        {
          nix = {
            settings = {
              experimental-features = [
                "nix-command"
                "flakes"
              ];
            };
          };

          services.localsend-rs.sopsBootstrap = true;

          environment.systemPackages = with pkgs; [
            git
          ];

          boot.isContainer = true;
          nixpkgs.hostPlatform = system;
          system.stateVersion = "25.11";
        }
      )
    ];
  };
}
