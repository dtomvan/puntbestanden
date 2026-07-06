{
  self,
  lib,
  inputs,
  ...
}:
{
  flake-inputs.nixocaine = {
    url = "git+https://git.madhouse-project.org/iocaine/nixocaine/?ref=stable";
    inputs.nixpkgs.follows = "nixpkgs";
    inputs.pre-commit-hooks.follows = "";
    inputs.treefmt-nix.follows = "";
  };

  flake.modules.nixos.profiles-hetzner-bakkie =
    { inputs', host, ... }:
    {
      imports = builtins.attrValues {
        inherit (inputs.srvos.nixosModules) server;

        inherit (self.modules.nixos)
          nix-sensible
          sops
          networking-wireguard
          services-ssh
          users-root
          services-nginx
          services-alertmanager
          ;

        inherit (inputs.nixocaine.nixosModules) default;
      };

      infra.monitoring.alertmanager.enable = lib.mkDefault true;

      systemd.network.networks."10-uplink".networkConfig.Address = lib.mkDefault host.networking.endpoint;

      time.timeZone = lib.mkForce "UTC";
      programs.command-not-found.enable = lib.mkForce false;
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

      boot.kernelPackages = inputs'.nixos-small.legacyPackages.linuxPackages_latest;

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

      # the journal can get huge on systems that serve (a lot of) HTTP requests
      # over the internet, such as matrix/nginx/forgejo, so we keep the journal
      # to a "slim" 1.5G in the case of commitit as of 2026-06-17, for instance
      services.journald.extraConfig = ''
        MaxRetentionSec=2week
      '';

      services.prometheus.exporters = {
        node.enable = lib.mkDefault true;
        systemd.enable = lib.mkDefault true;
      };
    };
}
