{ inputs, ... }:
{
  flake-inputs.nixocaine = {
    url = "git+https://git.madhouse-project.org/iocaine/nixocaine/?ref=stable";
    inputs.nixpkgs.follows = "nixpkgs";
    inputs.pre-commit-hooks.follows = "";
    inputs.treefmt-nix.follows = "";
  };

  flake.modules.nixos.services-iocaine =
    {
      config,
      pkgs,
      lib,
      inputs',
      ...
    }:
    let
      nsoePackage = inputs'.nixocaine.packages.nam-shub-of-enki.overrideAttrs {
        patches = [
          ./iocaine/0001-Add-contact-details.patch
        ];
      };
    in
    {
      imports = [ inputs.nixocaine.nixosModules.default ];

      services.iocaine.config = {
        # very random, yes
        initial-seed-file = "/run/current-system/boot.json";

        handler.main = {
          path = "${nsoePackage}";
          config = {
            inherits = "recommended";
            logging.classification.enable = true;
            sources = {
              wordlists =
                pkgs.fetchurl {
                  url = "https://cgit.git.savannah.gnu.org/cgit/miscfiles.git/plain/web2?id=fc51530ea66019efba9e961578df986a950cbb65";
                  hash = "sha256-KSmJWrP+x4xpY+vly7NJP+T8nhHroJWlInh7ivxTqGM=";
                }
                |> lib.singleton;

              training-corpus = [
                (pkgs.fetchurl {
                  url = "https://archive.org/download/GeorgeOrwells1984/1984_djvu.txt";
                  hash = "sha256-9R1PTa8yDtkfH+4rU5BF62ee73irhd3VYX1QB5KU+ZU=";
                })
                (pkgs.fetchurl {
                  url = "https://archive.org/download/ost-english-brave_new_world_aldous_huxley/Brave_New_World_Aldous_Huxley_djvu.txt";
                  hash = "sha256-6WkaO/3zQIezGzJDp4QjglikiTZTxgo0P4MEff2mdcY=";
                })
              ];
            };
            checks = {
              asn = {
                enable = true;
                filter_aggressives = true;
                # This file is unfree and requires setting up an account. Deliberately not using requireFile here.
                database_path = "/var/lib/iocaine/GeoLite2-ASN.mmdb";
              };
              anti_robots_txt.enable = true; # blocklist for specific bots that are known to not respect your robots.txt
              browser_verification.enable = false; # seems to trip up some old browsers, and also vivaldi
              commercial_scrapers.enable = true;
              cookie_monster = {
                enable = true;
                forgejo_challenge = "automatic";
              };
              firefox_ai.enable = true; # no thanks
              generated_urls = {
                enable = true;
                identifiers = [ "clanker_mode" ]; # default is a dot, which isn't a good idea
              };
              custom_agents = {
                allow = [
                  # used by IndieAuth
                  "Ruby"
                ];
              };
            };
          };
        };
      };

      sops.secrets.maxmind-credentials = {
        sopsFile = ../../secrets/maxmind-credentials.secret;
        mode = "0400";
        format = "binary";
      };

      systemd.services.iocaine-update-maxminddb = {
        wantedBy = [ "iocaine.service" ];
        before = [ "iocaine.service" ];
        after = [ "sops-install-secrets.service" ];
        requires = [ "sops-install-secrets.service" ];

        path = with pkgs; [
          coreutils
          curl
          gnutar
          gzip
        ];
        script = ''
          set -euo pipefail

          pushd "$STATE_DIRECTORY"

          # HACK: touch with very old timestamp when the file doesn't exist.
          # So we don't have to complicate the branching later down the line,
          # and stat will always succeed.
          if ! [ -e GeoLite2-ASN.mmdb ]; then
            touch -t 197001010001 GeoLite2-ASN.mmdb
          fi

          tarball="$(mktemp)"
          unpackdir="$(mktemp -d)"
          cleanup () {
            rm "$tarball"
            rm -r "$unpackdir"
            exit
          }
          trap cleanup EXIT ERR SIGINT

          last_modified="$(curl --write-out '%header{last-modified}' \
            -I -L -o /dev/null --silent \
            -u "$ACCOUNT_ID:$LICENSE_KEY" \
            'https://download.maxmind.com/geoip/databases/GeoLite2-ASN/download?suffix=tar.gz')"
          last_modified_s="$(date --date="$last_modified" +%s)"
          existing_mtime_s="$(stat -c %Y GeoLite2-ASN.mmdb)"

          if [ "$last_modified_s" -le "$existing_mtime_s" ]; then
            exit
          fi

          curl -o "$tarball" -J -L -u "$ACCOUNT_ID:$LICENSE_KEY" 'https://download.maxmind.com/geoip/databases/GeoLite2-ASN/download?suffix=tar.gz'
          tar -C "$unpackdir" -xzvf "$tarball"
          mv "$unpackdir"/*/GeoLite2-ASN.mmdb .
        '';
        serviceConfig = {
          EnvironmentFile = config.sops.secrets.maxmind-credentials.path;
          StateDirectory = "iocaine";
          DynamicUser = true;
          ProtectHome = true;
          MemoryDenyWriteExecute = true;
          PrivateDevices = true;
          ProtectSystem = "strict";
          ProtectControlGroups = true;
          RestrictSUIDSGID = true;
          RestrictRealtime = true;
          LockPersonality = true;
          ProtectKernelLogs = true;
          ProtectKernelTunables = true;
          ProtectHostname = true;
          ProtectKernelModules = true;
          PrivateUsers = true;
          ProtectClock = true;
        };
      };
    };
}
