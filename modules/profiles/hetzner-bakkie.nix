{
  self,
  lib,
  inputs,
  ...
}:
{
  flake.modules.nixos.profiles-hetzner-bakkie =
    { inputs', ... }:
    {
      imports = builtins.attrValues {
        inherit (inputs.srvos.nixosModules)
          server

          mixins-nginx
          ;

        inherit (self.modules.nixos)
          nix-sensible
          sops
          # TASK(20260516-084906): replace tailscale with wireguard for declaratively onboarding
          networking-tailscale
          services-ssh
          users-root
          ;
      };

      time.timeZone = lib.mkForce "UTC";
      users.mutableUsers = lib.mkDefault false;

      nix = {
        channel.enable = lib.mkForce false;
        gc.automatic = lib.mkForce false;
        settings = {
          experimental-features = [
            "nix-command"
            "flakes"
            "pipe-operators"
          ];
          max-jobs = lib.mkDefault 0;
        };
      };

      nixpkgs.flake = {
        setNixPath = lib.mkDefault false;
        setFlakeRegistry = lib.mkDefault false;
      };

      boot.kernelPackages = inputs'.nixos-small.legacyPackages.linuxPackages;

      networking = {
        useNetworkd = lib.mkForce true;
        firewall.enable = lib.mkForce true;
      };

      services.dbus.implementation = "dbus";

      programs.nh = {
        enable = lib.mkDefault true;
        clean = {
          enable = true;
          extraArgs = "--keep-since 2w --optimise";
          dates = "weekly";
        };
      };
    };
}
