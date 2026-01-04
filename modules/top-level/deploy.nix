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
      let
        inherit (v) hostName system;
        hostConfig = self.nixosConfigurations.${v.hostName};
      in
      lib.nameValuePair v.hostName {
        # yes.
        hostname = hostName;

        profiles.system = {
          user = "root";
          sshUser = "root";
          path = inputs.deploy-rs.lib.${system}.activate.nixos hostConfig;
        };

        profiles.tomvd = {
          user = "tomvd";
          path =
            inputs.deploy-rs.lib.${system}.activate.home-manager
              self.homeConfigurations."tomvd@${hostName}";
        };

        profiles.nixvim = {
          user = "tomvd";
          path =
            inputs.deploy-rs.lib.${system}.activate.custom self.packages.${system}.activatable-nixvim
              "./bin/activate";
        };

        profiles.flatpak = {
          user = "root";
          sshUser = "root";
          path = inputs.deploy-rs.lib.${system}.activate.custom (
            self.legacyPackages.${system}.activatable-flatpak
            {
              inherit (hostConfig.config.services.flatpak) packages;
            }
          ) "./bin/flatpak-managed-install";
        };
      }
    ))
  ];

  perSystem =
    { self', pkgs, ... }:
    {
      # TODO: this really bloats up a simple `nix flake check`. disabling it
      # for now, despite how eager the docs are to not have me do that
      # checks = inputs.deploy-rs.lib.${system}.deployChecks self.deploy;

      devshells.default.packages = with pkgs; [ deploy-rs ];

      # TODO: this is ugly, but yeah the API of deploy-rs doesn't seem really
      # flexible to me. How to fix?
      legacyPackages.activationPackage =
        args:
        pkgs.buildEnv {
          name = "activatable-${args.profileName}";
          paths = [
            args.profile
            (self'.legacyPackages.activate args)
          ];
        };

      # function that just plainly installs profiles with the thing it's meant
      # for: nix profile install..... why doesn't deploy-rs support this by default?
      legacyPackages.activate =
        {
          profile ? "\${PROFILE:?}",
          profileName,
        }:
        pkgs.writeShellApplication {
          name = "activate";
          runtimeInputs = with pkgs; [
            nix
            jq
          ];
          runtimeEnv = {
            NIX_CONFIG = "extra-experimental-features = nix-command flakes";
          };
          text = ''
            if nix profile list --json | jq -e '.elements.${profileName}' >/dev/null; then
              echo removing existing ${profileName} install...
              nix profile remove ${profileName}
            fi

            echo installing new ${profileName} install...
            nix profile install "${profile}"

            echo "done"
          '';
        };
    };
}
