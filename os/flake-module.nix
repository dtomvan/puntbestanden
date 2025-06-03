{ self, inputs, ... }:
with inputs.nixpkgs.lib;
let
  nixConfig = import ../nix-config.nix;

  getHosts = type: filterAttrs (_k: v: hasInfix type v.system) (import ../hosts.nix);
  mkPkgs = system: import ../lib/make-packages.nix { inherit self system inputs; };

  makeNixos =
    _key: host:
    nameValuePair host.hostName (nixosSystem {
      specialArgs = {
        inherit host nixConfig inputs;
      };
      modules = import ./modules.nix { inherit host inputs; } ++ host.os.extraModules; # nixpkgs is dumb
      pkgs = mkPkgs host.system;
    });

  system = "x86_64-linux";

  autounattend = nixosSystem {
    pkgs = mkPkgs system;
    modules = [
      ./autounattend/configuration.nix
      { nixpkgs.hostPlatform = system; }
    ];
    specialArgs = {
      inherit nixConfig inputs;
      host = {
        hostName = "nixos";
        inherit system;
        hardware.cpuVendor = "intel";
        os = {
          isGraphical = false;
          wantsKde = false;
        };
      };
    };
  };

  installer = nixosSystem {
    pkgs = mkPkgs system;
    modules = [
      inputs.sops.nixosModules.default
      ./autounattend/installer.nix
    ];
    specialArgs = {
      inherit nixConfig inputs;
      evaluatedSystem = autounattend;
    };
  };
in
{
  flake.nixosConfigurations = (mapAttrs' makeNixos (getHosts "linux")) // {
    inherit autounattend installer;
  };

  flake.packages.${system}.iso = self.nixosConfigurations.installer.config.system.build.isoImage;
}
