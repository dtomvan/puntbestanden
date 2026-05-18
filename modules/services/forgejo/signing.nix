let
  fjName = "Forgejo";
  fjEmail = "forgejo@git.toostveen.nl";
in
{
  flake.modules.nixos.services-forgejo =
    {
      pkgs,
      lib,
      config,
      ...
    }:
    let
      cfg = config.infra.fj.signing;

      inherit (lib)
        mkEnableOption
        mkMerge
        mkOption
        mkIf
        trim
        ;

      inherit (lib.types) str;

      gnupgHome = "/var/lib/forgejo/.gnupg";
    in
    {
      options.infra.fj.signing = {
        enable = mkEnableOption "declaratively signing commits using [repository.signing]";
        pubkeyId = mkOption {
          type = str;
          default = builtins.readFile ../../../secrets/forgejo-default-signing-key.fp |> trim;
        };
        privateKeyPath = mkOption {
          type = str;
          default = config.sops.secrets.forgejo-default-signing-key.path;
        };
        name = mkOption {
          type = str;
          default = fjName;
        };
        email = mkOption {
          type = str;
          default = fjEmail;
        };
      };

      config = mkMerge [
        {
          sops = {
            useSystemdActivation = lib.mkForce true;
            secrets.forgejo-default-signing-key = {
              format = "binary";
              sopsFile = ../../../secrets/forgejo-default-signing-key.secret;
              owner = config.services.forgejo.user;
              inherit (config.services.forgejo) group;
            };
          };
        }
        (mkIf cfg.enable {
          services.forgejo.settings."repository.signing" = {
            SIGNING_KEY = cfg.pubkeyId;
            SIGNING_NAME = cfg.name;
            SIGNING_EMAIL = cfg.email;
          };

          systemd.tmpfiles.settings."fj-gnupg"."${gnupgHome}".d = {
            inherit (config.services.forgejo) user group;
            mode = "0700";
          };

          systemd.services.forgejo.environment.GNUPGHOME = gnupgHome;

          systemd.services.fj-gnupg-import-key = {
            before = [ "forgejo.service" ];
            wantedBy = [ "forgejo.service" ];
            after = [ "sops-install-secrets.service" ];
            requires = [ "sops-install-secrets.service" ];
            path = [ pkgs.gnupg ];
            script = ''
              gpg --import ${cfg.privateKeyPath}
            '';
            environment.GNUPGHOME = gnupgHome;
            serviceConfig = {
              User = config.services.forgejo.user;
            };
          };
        })
      ];
    };

  perSystem =
    { pkgs, self', ... }:
    {
      packages.genfj = pkgs.writeShellApplication {
        name = "genfj";
        runtimeInputs = builtins.attrValues {
          inherit (pkgs)
            gawk
            gnupg
            mktemp
            sops
            coreutils
            ;
        };
        runtimeEnv.batchScript = builtins.toFile "genfj-gnupg-batch" ''
          %echo Generating a basic OpenPGP key
          %no-protection
          Key-Type: RSA
          Key-Length: 4096
          Name-Real: ${fjName}
          Name-Email: ${fjEmail}
          Expire-Date: 0
          %commit
        '';
        derivationArgs = {
          preferLocalBuild = true;
          allowSubstitutes = false;
        };
        inheritPath = false;
        text = ''
          GNUPGHOME="$(mktemp -d)"
          export GNUPGHOME
          gpg --batch --generate-key "''${batchScript:?}"
          fp="$(gpg --list-secret-keys --with-colons | awk -F: '$1 == "fpr" || $1 == "fp2" {print $10}' | head -n1)"
          echo "$fp" | tee secrets/forgejo-default-signing-key.fp
          gpg --armor --export "$fp" > secrets/forgejo-default-signing-key.pub
          gpg --armor --export-secret-keys "$fp" > secrets/forgejo-default-signing-key.secret
          sops encrypt --in-place secrets/forgejo-default-signing-key.secret
        '';
      };

      devshells.default.packages = [ self'.packages.genfj ];
    };
}
