{ self, ... }:
{
  perSystem = { self', pkgs, ... }: {
    devShells.blog = pkgs.mkShellNoCC {
      packages = builtins.attrValues {
        inherit (pkgs) coreutils git;
        inherit (pkgs.nur.repos.dtomvan) jorge;
      };
      shellHook = ''
        pushd "$(git rev-parse --show-toplevel)/modules/services/blog"

        nohup jorge serve &
      '';
    };

    packages.blog =
      pkgs.runCommand "my-jorge-blog"
        {
          preferLocalBuild = true;
          allowSubstitutes = false;

          nativeBuildInputs = [
            pkgs.nur.repos.dtomvan.jorge
            pkgs.envsubst
            pkgs.moreutils
          ];

          rev = if self ? sourceInfo.rev then "commit/${self.sourceInfo.rev}" else "branch/hoofdlijn";
        }
        ''
          cp -r ${./.}/* .
          chmod -R +w *

          ./build.sh

          cp -r target $out
        '';

    packages.blog-push = pkgs.writeShellApplication {
      name = "blog-push";
      runtimeInputs = [
        self'.packages.git-pages-push
      ];
      derivationArgs = {
        preferLocalBuild = true;
        allowSubstitutes = false;
      };
      inheritPath = false;
      text = ''
        git-pages-push ${self'.packages.blog} https://testing.toostveen.nl testing.toostveen.nl
        echo deployed to testing! is this ok?
        read -r -n 1 -p 'is this okay? [yN]' choice
        if [[ "$choice" =~ [yY] ]]; then
          git-pages-push ${self'.packages.blog} https://toostveen.nl toostveen.nl
        fi
      '';
    };
  };

  flake.modules.nixos.services-blog =
    { config, self', ... }:
    let
      inherit (import ../../_consts.nix) domain;
      port = 8754;
    in
    {
      imports = [
        self.modules.nixos.services-tyck
        self.modules.nixos.services-git-pages
      ];

      sops.secrets.tyck = {
        sopsFile = ../../../secrets/tyck-htpasswd.secret;
        owner = "tyck";
        group = "tyck";
        mode = "0440";
        format = "binary";
      };

      # TODO: setup email notifs (which email provider?? my own??!?!?!????)
      # or just fork the project so that it supports webhooks?
      services.tyck = {
        enable = true;
        host = domain;
        passwordFile = config.sops.secrets.tyck.path;
      };

      infra.git-pages = {
        enable = true;
        inherit port;
        caddyPort = null;
      };

      services.nginx.virtualHosts."${domain}" = {
        enableACME = true;
        forceSSL = true;

        serverAliases = [ "testing.${domain}" ];

        locations."/" = {
          proxyPass = "http://127.0.0.1:${toString port}";
          extraConfig = ''
            ssi on;
            proxy_pass_header Server;
            proxy_set_header Accept-Encoding "";
            proxy_intercept_errors on;
            error_page 404 = /.fallback/$uri;
          '';
        };

        locations."/.fallback" = {
          root = self'.packages.blog;
          extraConfig = ''
            ssi on;
          '';
        };
      };
    };
}
