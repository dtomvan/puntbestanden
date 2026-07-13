let
  caches = [
    "https://catppuccin.cachix.org"
    "https://noctalia.cachix.org"
    "https://nix-community.cachix.org"
    "https://attic.bartoostveen.nl/dtomvan-nur"
  ];
  trusted-public-keys = [
    "catppuccin.cachix.org-1:noG/4HkbhJb+lUAdKrph6LaozJvAeEEZj4N732IysmU="
    "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    "noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4="
    "dtomvan-nur:UyHAqPSYjeqV2WZalOzuEnsy9iqXiskJ0S31Y/gZUdw="
  ];
in
{ inputs, ... }:
{
  config = {
    flake-inputs.ncro = {
      url = "github:feel-co/ncro";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    flake.modules.nixos.profiles-workstation =
      {
        lib,
        options,
        config,
        inputs',
        ...
      }:
      {
        imports = [ inputs.ncro.nixosModules.default ];
        services.ncro = {
          enable = true;
          package = inputs'.ncro.packages.ncro.overrideAttrs {
            doCheck = false; # fail in nix sandbox for now.
          };
          settings = {
            upstreams = [
              {
                url = "https://cache.nixos.org";
                priority = 10;
              }
            ]
            ++
              lib.optional (options ? services.nix-cache-beacon && config.services.nix-cache-beacon.cache.enable)
                {
                  url = "http://localhost:5028";
                  priority = 20;
                }
            ++ map (url: {
              inherit url;
              priority = 20;
            }) caches;
          };
        };

        users.users.ncro = {
          isSystemUser = true;
          group = "ncro";
        };

        users.groups.ncro = { };

        sops.secrets.ncro-secret = lib.mkDefault {
          sopsFile = ../../secrets/ncro-${config.networking.hostName}.secret;
          owner = "ncro";
          group = "ncro";
          mode = "0440";
          format = "binary";
        };

        systemd.services.ncro.serviceConfig = {
          User = "ncro";
          Group = "ncro";
        };

        nix.settings = {
          inherit trusted-public-keys;

          substituters = lib.mkForce [
            "http://localhost:8080"
            # add a second cache.nixos.org here for in case ncro is broken/stopped
            "https://cache.nixos.org"
          ];
          extra-substituters = lib.mkForce [ ];
        };
      };

    perSystem =
      { pkgs, ... }:
      {
        packages.genncro = pkgs.writeShellApplication {
          name = "genncro";
          runtimeInputs = builtins.attrValues {
            inherit (pkgs)
              coreutils
              gitMinimal
              gnugrep
              gnused
              hostname-debian
              openssl
              sops
              ;
          };
          derivationArgs = {
            preferLocalBuild = true;
            allowSubstitutes = false;
          };
          inheritPath = false;
          text = ''
            pushd "$(git rev-parse --show-toplevel)"
            hostname="''${1:-$(hostname)}"

            tmp="$(mktemp -d)"
            cleanup () {
              rm -r "$tmp"
              exit
            }
            trap cleanup EXIT ERR SIGINT

            privkey="secrets/ncro-$hostname.secret"
            pubkey="secrets/ncro-$hostname.pub"
            openssl genpkey -algorithm ED25519 -pass pass: -out "$tmp/privkey.pem"
            openssl pkey -noout -text -in "$tmp/privkey.pem" | grep -A3 pub | sed -E 's/[ :]//g' | tail -n3 | paste -sd ''' > "$pubkey"
            # shellcheck disable=SC2094
            cat "$tmp/privkey.pem" | sops encrypt --filename-override "$privkey" > "$privkey"
          '';
        };
      };
  };
}
