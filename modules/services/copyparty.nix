{ inputs, lib, ... }:
{
  flake-file.inputs.copyparty = {
    # TODO: bump manually on new release, you could make a flake app that does
    # this but yeah it doesn't really matter
    url = "github:9001/copyparty/v1.18.4";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  pkgs-overlays = [ inputs.copyparty.overlays.default ];

  flake.modules.nixos.profiles-base =
    { config, pkgs, ... }:
    let
      package = pkgs.copyparty.override {
        withFastThumbnails = true;
      };
    in
    {
      imports = [ inputs.copyparty.nixosModules.default ];

      sops.secrets.copyparty = {
        mode = "0400";
        sopsFile = ../../secrets/copyparty.secret;
        format = "binary";
        owner = "tomvd";
        group = "users";
      };

      environment.systemPackages = [ package ];

      services.copyparty = {
        enable = true;
        inherit package;

        user = "tomvd";
        group = "users";

        settings = {
          p = "80";
          e2dsa = true;
          e2ts = true;
          dedup = true;
          shr = "/shares";
          hist = "/var/lib/copyparty/";
          theme = 2; # monokai
          # just a normal spinner
          spinner = ",padding:0;border-radius:9em;border:.2em solid #444;border-top:.2em solid #fc0";
        };

        accounts.tomvd.passwordFile = config.sops.secrets.copyparty.path;

        volumes = {
          "/" = {
            path = "/home/tomvd";
            access.A = [ "tomvd" ];
            flags = {
              hardlinkonly = true;
              fk = 4;
              noidx = lib.concatStringsSep "|" [
                "\\.iso$"
                "^/home/tomvd/\\."
                ".*/\\.git/.*"
                ".*/\\.jj/.*"
                ".*/\\.direnv/.*"
                ".*/nix/store/.*"
              ];
            };
          };
        };
      };

      systemd.services.copyparty.serviceConfig = {
        # allow port < 2^10
        AmbientCapabilities = [ "CAP_NET_BIND_SERVICE" ];
      };
    };
}
