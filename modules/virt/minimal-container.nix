{ self, ... }:
{
  flake.nixosConfigurations.minimal-container = self.legacyPackages.x86_64-linux.nixosSystem {
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
          system.stateVersion = "26.11";
        }
      )
    ];
  };
}
