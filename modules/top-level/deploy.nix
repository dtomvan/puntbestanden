{
  self,
  lib,
  inputs,
  ...
}:
{
  flake-file.inputs = {
    deploy-rs = {
      url = "github:serokell/deploy-rs";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-compat.follows = "";
    };
  };

  flake.deploy.nodes = lib.pipe self.hosts [
    (lib.filterAttrs (_n: v: !(v ? noConfig)))
    (lib.mapAttrs' (
      _n: v:
      lib.nameValuePair v.hostName {
        # yes.
        hostname = v.hostName;

        profiles.system = {
          user = "root";
          sshUser = "root";
          path = inputs.deploy-rs.lib.${v.system}.activate.nixos self.nixosConfigurations.${v.hostName};
        };

        profiles.tomvd = {
          user = "tomvd";
          path =
            inputs.deploy-rs.lib.${v.system}.activate.home-manager
              self.homeConfigurations."tomvd@${v.hostName}";
        };
      }
    ))
  ];

  perSystem =
    { pkgs, ... }:
    {
      # TODO: this really bloats up a simple `nix flake check`. disabling it
      # for now, despite how eager the docs are to not have me do that
      # checks = inputs.deploy-rs.lib.${system}.deployChecks self.deploy;

      devshells.default.packages = with pkgs; [ deploy-rs ];
    };

  flake.modules.nixos.profiles-base =
    { pkgs, ... }:
    {
      environment.systemPackages = with pkgs; [ deploy-rs ];
    };

  # TODO: deploy home-manager
}
