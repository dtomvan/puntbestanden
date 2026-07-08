toplevel@{ self, lib, ... }:
{
  flake.modules.nixos.services-syncthing =
    { config, host, ... }:
    let
      username = "tomvd";
      devices =
        toplevel.config.hosts
        |> lib.filterAttrs (_: h: builtins.pathExists ./_ids/${h.networking.hostName})
        |> lib.mapAttrs (
          _: h: {
            id = builtins.readFile ./_ids/${h.networking.hostName} |> lib.trim;
            autoAcceptFolders = true;
          }
        )
        |> (
          a:
          a
          // {
            "Nothing Phone (3a)" = {
              id = "3P4JOUH-NHDCUVU-I2QGOZ6-LNV7CPI-RMMZQEA-ZW3HR7X-LI46MSB-N7UIYQP";
              autoAcceptFolders = false;
            };
          }
        );
      notServers = builtins.attrNames devices |> lib.filter (n: n != "hetzner1");
      allDevices = builtins.attrNames devices;
      isCommitit = host == toplevel.config.hosts.hetzner1;
      ignoreCopyparty = lib.singleton ".hist";
      folders =
        lib.optionalAttrs (!isCommitit) {
          default = {
            path = "~/Sync";
            devices = notServers;
            ignorePatterns = ignoreCopyparty;
          };
          Documents = {
            id = "kmfc4-cvogr";
            path = "~/Documents";
            devices = notServers;
            ignorePatterns = ignoreCopyparty;
            versioning = {
              type = "trashcan";
              params.cleanoutDays = "90";
            };
          };
          Pictures = {
            id = "xzsp4-pibte";
            path = "~/Pictures";
            devices = notServers;
            ignorePatterns = ignoreCopyparty;
            versioning = {
              type = "trashcan";
              params.cleanoutDays = "30";
            };
          };
          Music = {
            id = "pmac7-de6gr";
            path = "~/Music";
            devices = notServers;
            ignorePatterns = ignoreCopyparty;
            versioning = {
              type = "trashcan";
              params.cleanoutDays = "30";
            };
          };
        }
        // {
          # TASK(20260524-141049): figure out how to refactor
          forgejo = {
            id = "sda23-jklj8";
            path = if isCommitit then "/var/lib/forgejo" else "~/Forgejo";
            type = if isCommitit then "sendonly" else "receiveonly";
            devices = allDevices;
            versioning = {
              type = "trashcan";
              params.cleanoutDays = "90";
            };
          };
          hedgedoc = {
            id = "add98-dey7m";
            path = if isCommitit then "/var/lib/hedgedoc" else "~/Hedgedoc";
            type = if isCommitit then "sendonly" else "receiveonly";
            devices = allDevices;
            versioning = {
              type = "trashcan";
              params.cleanoutDays = "90";
            };
          };
        };
    in
    {
      imports = [ self.modules.nixos.sops ];

      sops.secrets.syncthing = {
        mode = "0400";
        sopsFile = ../../../secrets/syncthing.${config.networking.hostName}.secret;
        format = "binary";
        owner = config.services.syncthing.user;
        inherit (config.services.syncthing) group;
      };

      sops.secrets.syncthing-gui-password = {
        mode = "0400";
        sopsFile = ../../../secrets/syncthing-gui-password.secret;
        format = "binary";
        owner = config.services.syncthing.user;
        inherit (config.services.syncthing) group;
      };

      users.groups.syncthing = { };
      users.users.tomvd.extraGroups = [
        "syncthing"
        "forgejo"
        "hedgedoc"
      ];

      systemd.tmpfiles.settings."10-stfolder" = lib.mkIf isCommitit {
        "/var/lib/forgejo/.stfolder".d = { };
        "/var/lib/hedgedoc/.stfolder".d = { };
      };

      services.syncthing = {
        enable = true;
        group = "syncthing";
        user = username;
        dataDir = "/home/${username}";
        guiAddress = lib.mkIf isCommitit "10.0.0.3:8384";
        guiPasswordFile = config.sops.secrets.syncthing-gui-password.path;

        extraFlags = [ "--allow-newer-config" ];

        settings = {
          inherit devices folders;

          cert = _pubkeys/${config.networking.hostName}.pem;
          key = config.sops.secrets.syncthing.path;

          options.urAccepted = 3;
        };
      };
    };

  perSystem =
    { pkgs, ... }:
    {
      packages.genst = pkgs.writeShellApplication {
        name = "genst";
        runtimeInputs = builtins.attrValues {
          inherit (pkgs)
            gitMinimal
            hostname-debian
            coreutils
            syncthing
            xml2
            ripgrep
            ;
        };
        text = ''
          pushd "$(git rev-parse --show-toplevel)"
          hostname="''${1:-$(hostname)}"
          tmp="$(mktemp -d)"
          cleanup () {
            rm -r "$tmp"
            exit
          }
          trap cleanup EXIT ERR SIGINT

          syncthing generate --home="$tmp"
          mkdir -p modules/services/syncthing/_ids modules/services/syncthing/_pubkeys secrets
          cp "$tmp/cert.pem" "modules/services/syncthing/_pubkeys/$hostname.pem"
          xml2 < "$tmp/config.xml" | rg '^/configuration/device/@id=(.*)' -r '$1' > "modules/services/syncthing/_ids/$hostname"

          target="secrets/syncthing.$hostname.secret"
          # shellcheck disable=SC2094
          cat "$tmp/key.pem" | sops encrypt --filename-override "$target" > "$target"
        '';
      };
    };
}
