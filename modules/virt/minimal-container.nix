{ inputs, ... }:
{
  flake.nixosConfigurations.minimal-container = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      (
        { pkgs, ... }:
        {
          nix.settings.experimental-features = [
            "nix-command"
            "flakes"
          ];

          nixpkgs.flake.setFlakeRegistry = true;

          environment.systemPackages = [ pkgs.git ];

          boot.isContainer = true;
          nixpkgs.hostPlatform = "x86_64-linux";
          system.stateVersion = "25.11";
        }
      )
    ];
  };
}
