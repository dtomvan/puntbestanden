{ self, ... }:
{
  # define a bash script which actually does the thing...
  perSystem =
    { pkgs, lib, ... }:
    {
      packages.disk-usage-analyzer = pkgs.callPackage (
        {
          writeShellApplication,
          coreutils,
          dust,
          gum,
          jq,
          util-linux,
          # NOT escaped.
          defaultBuckets ? [ ],
        }:
        writeShellApplication {
          name = "disk-usage-analyzer";
          runtimeInputs = [
            coreutils
            dust
            gum
            jq
            util-linux
          ];
          passthru = { inherit defaultBuckets; };
          text = ''
            declare -a buckets

            function printbuckets {
              for bucket in "''${buckets[@]}"; do
                echo "  - $bucket"
              done
            }

            function usage {
              echo "Usage: $0 [TARGET] [BUCKETS...]"
              echo "  get the total disk usage in TARGET, and group into BUCKETS"
              echo
            }

            function checkbuckets {
              if [ "''${#buckets[@]}" -eq 0 ]; then
                echo "ERROR: no buckets configured"
                usage
                exit 1
              fi


              for bucket in "''${buckets[@]}"; do
                stat "$bucket" >/dev/null
              done
            }

            buckets+=(
              ${lib.concatLines defaultBuckets}
            )

            if [ $# -gt 0 ] && [ "$1" == --help ]; then
              usage
              echo "  the default buckets are:"
              printbuckets
              exit 1
            fi

            target="''${1:-/}"
            [ $# -gt 0 ] && shift

            buckets+=("$@")

            checkbuckets

            user="$(whoami)"
            curdisk="$(df "$target" --output=source | tail -n1)"
            df_bytes="$(df -B1 "$target" --output=used | tail -n1)"
            df="$(numfmt --to=iec "$df_bytes")"

            if [ "$user" != root ]; then
              echo "Not running as root. Tip: run with \`sudo --preserve-env=HOME $0\` when bucketting paths that cannot be indexed as a regular user."
            fi

            echo "User: $user"
            echo "Home: ''${HOME:-/home/user}"
            echo "Disk /: $curdisk"
            echo "Total disk usage for /: $df"
            echo
            echo "Selected buckets:"
            printbuckets
            gum confirm "Run dust on these paths?" || exit 1
            echo

            buckets_j="$(gum spin --title="Calculating buckets..." --show-stdout -- dust -d 0 -j "''${buckets[@]}")"
            total="$(jq -r '.size' <<< "$buckets_j")"
            total_bytes="$(numfmt --from=iec "$total")"
            other_bytes="$((df_bytes - total_bytes))"
            other="$(numfmt --to=iec "$other_bytes")"
            echo 
            cat \
              <(jq -r '.children | map([.name, .size]) | .[] | @tsv' <<< "$buckets_j") \
              <(printf "Total\t%s\n" "$total") \
              <(printf "Other\t%s\n" "$other") \
              | column -t
          '';
        }
      ) { };
    };

  # make it configurable with a nixos module
  flake.modules.nixos.disk-usage-analyzer =
    {
      pkgs,
      lib,
      config,
      ...
    }:
    let
      cfg = config.programs.disk-usage-analyzer;
      finalPackage = cfg.package.override {
        inherit (cfg.settings) defaultBuckets;
      };
      detectedBuckets =
        lib.optionals config.programs.steam.enable [ "~/.steam/steam" ]
        ++ lib.optionals config.boot.enableContainers [ "/var/lib/nixos-containers" ]
        ++ lib.optionals config.programs.firefox.enable [ "~/.mozilla/firefox" ]
        ++ lib.optionals config.services.flatpak.enable [
          "~/.var"
          "/var/lib/flatpak"
        ]
        ++ lib.optionals config.services.pinchflat.enable [ "/var/lib/pinchflat" ]
        ++ lib.optionals config.virtualisation.docker.enable [ "/var/lib/docker" ]
        ++ lib.optionals config.virtualisation.libvirtd.enable [ "/var/lib/libvirt" ]
        ++ lib.optionals config.virtualisation.podman.enable [
          "~/.local/share/containers"
          "/var/lib/containers"
        ]
        ++ lib.optionals config.virtualisation.waydroid.enable [
          "/var/lib/waydroid"
          "~/.local/share/waydroid"
        ];
    in
    {
      options.programs.disk-usage-analyzer = {
        enable = lib.mkEnableOption "disk usage analyzer CLI";
        package = lib.mkOption {
          description = "the `disk-usage-analyzer' package to use";
          type = lib.types.package;
          default = self.packages.${pkgs.stdenv.hostPlatform.system}.disk-usage-analyzer;
        };
        finalPackage = lib.mkOption {
          type = lib.types.package;
          visible = false;
          readOnly = true;
          description = "Resulting customized `disk-usage-analyzer' package";
        };

        settings = {
          defaultBuckets = lib.mkOption {
            description = "list of (bash-escaped) paths to bucket in the analyzer, escape yourself if needed";
            type = with lib.types; listOf str;
            default = [ ];
            example = [
              "$HOME/.cache"
              "/var/lib/libvirt"
            ];
          };
          detectBuckets = lib.mkEnableOption "automatically detecting which buckets might be relevant given the rest of the system config";
        };
      };

      config = {
        programs.disk-usage-analyzer = {
          inherit finalPackage;
          settings.defaultBuckets = [
            "/nix/store"
            "~/.cache"
            "~/.config" # gets big because electron apps
            "~/Documents"
            "~/Downloads"
            "~/Music"
            "~/Pictures"
            "~/Videos"
          ]
          ++ lib.optionals cfg.settings.detectBuckets detectedBuckets;
        };
        environment.systemPackages = lib.optional cfg.enable finalPackage;
      };
    };

  # enable this for all graphical systems as it won't change the system closure much
  flake.modules.nixos.profiles-graphical =
    { lib, ... }:
    {
      imports = [ self.modules.nixos.disk-usage-analyzer ];
      programs.disk-usage-analyzer = {
        enable = lib.mkDefault true;
        settings.detectBuckets = lib.mkDefault true;
      };
    };

  # set some more for boomer
  flake.modules.nixos.hosts-boomer.programs.disk-usage-analyzer.settings.defaultBuckets = [
    "~/repos"
    "~/projects"
  ];

  # set an alias for home-manager (yes, I know dua exists, but I'll run that one thru comma)
  flake.modules.homeManager.basic-cli.programs.bash.shellAliases.dua = "disk-usage-analyzer";
}
