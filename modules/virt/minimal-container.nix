{
  self,
  inputs,
  ...
}:
let
  system = "x86_64-linux";
in
{
  flake.nixosConfigurations.minimal-container = inputs.nixpkgs.lib.nixosSystem {
    modules = with self.modules.nixos; [
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

          environment.systemPackages = with pkgs; [ git ];

          boot.isContainer = true;
          nixpkgs.hostPlatform = system;
          system.stateVersion = "25.11";
        }
      )
    ];
  };
}
