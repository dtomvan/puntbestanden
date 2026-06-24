{ inputs, lib, ... }:
let
  defaultDomain = "fs.${(import ../_consts.nix).domain}";

  inherit (lib)
    mkEnableOption
    mkIf
    mkMerge
    mkOption
    mkOptionDefault
    mkPackageOption
    optionalAttrs
    optionals
    ;

  inherit (lib.types)
    attrsOf
    listOf
    nullOr
    passwdEntry
    port
    raw
    str
    ;
in
{
  flake-inputs.copyparty = {
    url = "github:9001/copyparty";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  pkgs-overlays = [
    inputs.copyparty.overlays.default
  ];

  flake.modules.nixos.services-copyparty =
    {
      config,
      pkgs,
      ...
    }:
    let
      cfg = config.infra.copy;
      mkCopypartyVolumeOptions = name: {
        enable = mkEnableOption "/${name} endpoint";

        access = mkOption {
          type = listOf str |> attrsOf;
          default = { };
        };

        path = mkOption {
          type = str;
          default = "/var/lib/copyparty/${name}";
        };

        extraFlags = mkOption {
          type = attrsOf raw;
          default = { };
        };
      };
    in
    {
      imports = [ inputs.copyparty.nixosModules.default ];

      options.infra.copy = {
        enable = mkEnableOption "copyparty";

        package = mkPackageOption pkgs "copyparty-unstable" {
          default = pkgs.copyparty-unstable.override {
            withFastThumbnails = true;
            withMediaProcessing = false; # uses ffmpeg, which can eat your CPU big time
            # uses mutagen, should be quicker as well, also saves closure size!
            withBasicAudioMetadata = true;
          };
        };

        enableRecommendedSettings = mkEnableOption "recommended settings";

        user = mkOption {
          type = passwdEntry str;
          default = if cfg.nginx.enable then "nginx" else "copyparty";
        };

        group = mkOption {
          type = passwdEntry str;
          default = if cfg.nginx.enable then "nginx" else "copyparty";
        };

        port = mkOption {
          type = nullOr port;
          default = null;
        };

        nginx = {
          enable = mkEnableOption "don't open a port, use nginx instead";

          unixSocket = mkOption {
            description = "socket that both nginx and copyparty agree on to proxy the service";
            type = str;
            default = "/run/copyparty/party.sock";
          };

          domain = mkOption {
            type = str;
            default = defaultDomain;
          };

          extraVirtualHostSettings = mkOption {
            type = attrsOf raw;
            default = { };
          };
        };

        drop = mkCopypartyVolumeOptions "drop";
        paste = mkCopypartyVolumeOptions "paste";
        scrot = mkCopypartyVolumeOptions "scrot";

        admin = {
          username = mkOption {
            type = str;
            default = "admin";
          };
          passwordFile = mkOption {
            default = config.sops.secrets.copyparty.path;
            type = str;
          };
        };
      };

      config = mkMerge [
        {
          assertions = [
            {
              assertion = cfg.port != null -> !cfg.nginx.enable;
              message = "can't set a port if copyparty is managed by nginx";
            }
            {
              assertion = cfg.nginx.enable || (cfg.port != null);
              message = "need to either configure a port or enable nginx";
            }
          ];

          sops.secrets.copyparty = {
            mode = "0400";
            sopsFile = ../../secrets/copyparty.secret;
            format = "binary";
            owner = cfg.user;
            inherit (cfg) group;
          };

          infra.copy = {
            drop.access = mkOptionDefault {
              A = [ cfg.admin.username ];
              wG = [ "*" ];
            };
            paste.access = mkOptionDefault {
              A = [ cfg.admin.username ];
              G = [ "*" ];
            };
            scrot.access = mkOptionDefault {
              A = [ cfg.admin.username ];
              G = [ "*" ];
            };
          };
        }

        (mkIf cfg.enable {
          # @bartoostveen [
          systemd.sockets.copyparty = lib.mkIf cfg.nginx.enable {
            before = [ "nginx.service" ];
            wantedBy = [ "sockets.target" ];
            socketConfig = {
              ListenStream = cfg.nginx.unixSocket;
              SocketUser = cfg.user;
              SocketGroup = cfg.group;
              SocketMode = "770";
            };
          };

          systemd.services.copyparty = {
            requires = [
              "sops-install-secrets.service"
            ]
            ++ optionals cfg.nginx.enable [
              "copyparty.socket"
            ];
            after = [ "sops-install-secrets.service" ];
          };

          services.nginx.virtualHosts."${cfg.nginx.domain}" = mkIf cfg.nginx.enable {
            enableACME = true;
            forceSSL = true;
            locations."/" = {
              proxyPass = "http://unix://${cfg.nginx.unixSocket}";
              proxyWebsockets = true;
              extraConfig = ''
                client_max_body_size 0;
                proxy_buffering off;
                proxy_request_buffering off;
                proxy_buffers 32 8k;
                proxy_buffer_size 16k;
                proxy_busy_buffers_size 24k;
              '';
            };
          };

          # ]

          environment.systemPackages = [ cfg.package ];

          services.copyparty = {
            enable = true;
            inherit (cfg) package user group;

            settings = {
              ### connection
              # e.g. boomerparty, featherparty
              name = "${config.networking.hostName}party";
            }
            // optionalAttrs cfg.enableRecommendedSettings {
              no-robots = true;

              ### paths
              shr = "/shares";

              e2dsa = true; # enable indexing
              dedup = true;
              theme = 2; # monokai
              # just a normal spinner
              spinner = ",padding:0;border-radius:9em;border:.2em solid #444;border-top:.2em solid #fc0";

              forget-ip = 10080; # week, apparently to comply with GDPR

              # useful if you have podcasts or whatever
              rss = true;

              # human-readable file size: SI format, 2 decimals (1.18 MB)
              ui-filesz = "4c";
            }
            // optionalAttrs cfg.nginx.enable {
              i = "unix:770:${cfg.nginx.unixSocket},0.0.0.0";
              # reverse proxy (@bartoostveen)
              # Trust that nginx is configured correctly
              xff-hdr = "x-forwarded-for";
              rproxy = 1;
              daw = true;
              dont-ban = "aa"; # Do not ban folks that have admin anywhere
            }
            // optionalAttrs (!cfg.nginx.enable) {
              p = cfg.port;
            };

            accounts.${cfg.admin.username} = { inherit (cfg.admin) passwordFile; };

            volumes =
              let
                commonFlags = {
                  hardlinkonly = true;
                  # adds some extra random stuff so the file is a little more
                  # "secret"
                  fka = 8;
                  # cannot download partial uploads
                  nopipe = true;
                  # no thumbnails
                  dthumb = true;
                  # you do not get to choose the filename
                  rand = true;
                  # No XSS please
                  nohtml = true;
                  # no subfolders
                  nosub = true;
                  # always leave at least 4g of available disk space
                  df = "4g";
                };
              in
              {
                "/pub" = {
                  path = "/srv/copyparty/pub";
                  access = {
                    A = [ cfg.admin.username ];
                    r = [ "*" ];
                  };
                };
                "/priv" = {
                  path = "/srv/copyparty/priv";
                  access.A = [ cfg.admin.username ];
                };
              }
              // optionalAttrs cfg.drop.enable {
                "/drop" = {
                  inherit (cfg.drop) path access;
                  flags =
                    commonFlags
                    // {
                      # no more than 300 mb over 15 minutes
                      maxb = "300m,600";
                      # max 100 mb uploads
                      sz = "0-100m";
                      # little less than a quarter
                      lifetime = 60 * 60 * 24 * 30 * 4;
                    }
                    // cfg.drop.extraFlags;
                };
              }
              // optionalAttrs cfg.paste.enable {
                "/paste" = {
                  inherit (cfg.paste) path access;
                  flags =
                    commonFlags
                    // {
                      # no more than 20 mb over 15 minutes
                      maxb = "20m,600";
                      # max 10 mb uploads
                      sz = "0-10m";
                    }
                    // cfg.paste.extraFlags;
                };
              }
              // optionalAttrs cfg.scrot.enable {
                "/scrot" = {
                  inherit (cfg.scrot) path access;
                  flags =
                    commonFlags
                    // {
                      # no more than 20 mb over 15 minutes
                      maxb = "20m,600";
                      # max 5 mb uploads
                      sz = "0-5m";
                    }
                    // cfg.paste.extraFlags;
                };
              };
          };
        })
      ];
    };

  perSystem =
    { pkgs, inputs', ... }:
    {
      packages.pb = pkgs.writeShellApplication {
        name = "pb";
        runtimeInputs = builtins.attrValues {
          # unoverlayed because otherwise it's broken
          inherit (inputs'.nixpkgs.legacyPackages)
            copyparty-min
            ;
          inherit (pkgs)
            sops
            coreutils
            file
            gawk
            ;
        };
        derivationArgs = {
          preferLocalBuild = true;
          allowSubstitutes = false;
        };
        text = ''
          tmp="$(mktemp)"
          cat > "$tmp"
          ext="$(file --brief --extension "$tmp" | awk -F/ '{ print $1 }')"
          mime="$(file --brief --mime-type "$tmp")"
          case "$ext" in
            png | jpg | jpeg)
              drop="scrot";;
            *)
              if [ "$mime" = "application/xhtml+xml" ] || [ "$mime" = "text/html" ]; then
                drop="paste"
                ext="html"
              elif [[ "$mime" =~ ^text/ ]]; then
                drop="paste"
                ext="txt"
              else
                drop="priv"
              fi
              ;;
          esac
          mv "$tmp" "$tmp.$ext"
          u2c -u -a "$(sops decrypt ${../../secrets/copyparty.secret})" "''${1:-"https://${defaultDomain}/$drop"}" "$tmp.$ext"
          rm "$tmp.$ext"
        '';
      };

      packages.scratch = pkgs.writeShellApplication {
        name = "scratch";
        runtimeInputs = builtins.attrValues {
          inherit (pkgs) coreutils wl-clipboard;
        };
        derivationArgs = {
          preferLocalBuild = true;
          allowSubstitutes = false;
        };
        text = ''
          tmp="$(mktemp | tee /dev/stderr >(wl-copy))"
          tee "$tmp"
        '';
      };
    };

  flake.modules.nixos.profiles-workstation =
    { self', ... }:
    {
      environment.systemPackages = builtins.attrValues {
        inherit (self'.packages) pb scratch;
      };
    };
}
