{ inputs, lib, ... }:
{
  flake-file.inputs.copyparty = {
    # TODO: bump manually on new release, you could make a flake app that does
    # this but yeah it doesn't really matter
    url = "github:9001/copyparty/cbdbaf193896dc83392f65f67a18744d898efd7e";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  pkgs-overlays = [ inputs.copyparty.overlays.default ];

  flake.modules.nixos.profiles-base =
    { config, pkgs, ... }:
    let
      package = pkgs.copyparty.override {
        withFastThumbnails = true;
      };
      u2c = pkgs.stdenvNoCC.mkDerivation {
        pname = "u2c";
        inherit (package) version meta;
        src = inputs.copyparty;

        nativeBuildInputs = [ pkgs.makeBinaryWrapper ];

        installPhase = ''
          runHook preInstall

          install -Dm444 bin/u2c.py -t $out/share/copyparty
          mkdir $out/bin
          makeWrapper ${lib.getExe pkgs.python312} $out/bin/u2c \
            --add-flag $out/share/copyparty/u2c.py

          runHook postInstall
        '';
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

      environment.systemPackages = [
        package
        u2c
      ];

      services.copyparty = {
        enable = true;
        inherit package;

        user = "tomvd";
        group = "users";

        settings = {
          p = "80";
          # e.g. boomerparty, featherparty
          name = "${config.networking.hostName}party";
          z = true;
          e2dsa = true;
          dedup = true;
          shr = "/shares";
          hist = "/var/lib/copyparty/";
          theme = 2; # monokai
          # just a normal spinner
          spinner = ",padding:0;border-radius:9em;border:.2em solid #444;border-top:.2em solid #fc0";
        };

        accounts.tomvd.passwordFile = config.sops.secrets.copyparty.path;

        volumes =
          let
            access.A = [ "tomvd" ];
          in
          {
            "/" = {
              inherit access;
              path = "/home/tomvd";
              flags = {
                hardlinkonly = true;
                fk = 4;
                # please support gitignore
                noidx = lib.concatStringsSep "|" [
                  ''\.iso$''
                  ''^/home/tomvd/\.''
                  ''^/home/tomvd/repos''
                  ''^/home/tomvd/projects''
                  ''.*/\.git/.*''
                  ''.*/\.jj/.*''
                  ''.*/\.direnv/.*''
                  ''.*/\.flox/.*''
                  ''.*/nix/store/.*''
                  ''.*/result.*''
                  ''.*/repl-result.*''
                ];
              };
            };

            "/Music" = {
              path = "/home/tomvd/Music";
              access = access // {
                r = "*";
              };
              flags.e2ts = true;
            };

            "/Documents" = {
              inherit access;
              path = "/home/tomvd/Documents";
              flags.e2ts = true;
            };

            "/drop" = {
              access = access // {
                # you can only see the files if you know exactly the path and
                # the file key.
                wG = "*";
              };
              path = "/var/lib/copyparty/copyparty/drop/";
              flags = {
                hardlinkonly = true;
                # adds some extra random stuff so the file is a little more
                # "secret"
                fka = 8;
                # cannot download partial uploads
                nopipe = true;
                # sort uploads by date
                # this one seems buggy
                # rotf = "%Y-%m-%d";
                # no thumbnails
                dthumb = true;
                # little less than a quarter
                lifetime = 60 * 60 * 24 * 30 * 4;
                # no more than 500 mb over 15 minutes
                maxb = "500m,600";
                # you do not get to choose the filename
                rand = true;
                # max 200 mb uploads
                sz = "0-200m";
                # always leave a little more than my system closure size
                df = "20g";
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
