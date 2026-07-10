let
  iocainePort = 23363;
in
{ self, ... }:
{
  flake.modules.nixvim.default.lsp.servers.oxfmt.enable = true;

  perSystem = { self', pkgs, ... }: {
    treefmt.programs.oxfmt = {
      enable = true;
      excludes = [ "README.md" ];
    };

    files."modules/programs/firefox/blogroll.json" =
      pkgs.runCommand "blogroll.json"
        {
          nativeBuildInputs = [
            pkgs.jq
            pkgs.nur.repos.dtomvan.jorge
          ];
        }
        ''
          pushd ${./.}
          jorge meta site.config.blogroll | jq 'sort_by(.name)' > $out
        '';

    devShells.blog = pkgs.mkShellNoCC {
      packages = builtins.attrValues {
        inherit (pkgs) coreutils git;
        inherit (pkgs.nur.repos.dtomvan) jorge;
        inherit (self'.packages) send-webmention blog-push;
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

          REV = if self ? sourceInfo.rev then "commit/${self.sourceInfo.rev}" else "branch/hoofdlijn";
        }
        ''
          cp -r ${./.}/* .
          chmod -R +w *

          bash build.sh

          cp -r target $out
        '';

    packages.send-webmention = pkgs.writeShellApplication {
      name = "send-webmention";
      runtimeInputs = builtins.attrNames {
        inherit (pkgs) coreutils gnugrep curl;
      };
      derivationArgs = {
        preferLocalBuild = true;
        allowSubstitutes = false;
      };
      text = ''
        my_url="''${1:?}"
        target_url="''${2:?}"

        curl -i -d "source=$my_url&target=$target_url" "$(curl -i -s "$target_url" | grep 'rel="webmention"' | grep -o -E 'https?://[^ ">]+' | sort | uniq)"
      '';
    };

    packages.blog-push = pkgs.writeShellApplication {
      name = "blog-push";
      runtimeInputs = [
        self'.packages.git-pages-push
        pkgs.gitMinimal
      ];
      derivationArgs = {
        preferLocalBuild = true;
        allowSubstitutes = false;
      };
      text = ''
        pushd "$(git rev-parse --show-toplevel)"
        blog="$(nix build .#blog --print-out-paths)"
        git-pages-push "$blog" https://testing.toostveen.nl testing.toostveen.nl
        echo deployed to testing! is this ok?
        read -r -n 1 -p 'is this okay? [yN]' choice
        if [[ "$choice" =~ [yY] ]]; then
          git-pages-push "$blog" https://toostveen.nl toostveen.nl
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
        settings.enable-javascript = true;
        host = domain;
        passwordFile = config.sops.secrets.tyck.path;
      };

      infra.git-pages = {
        enable = true;
        inherit port;
        caddyPort = null;
      };

      services.iocaine = {
        enable = true;
        config = {
          server = {
            blog = {
              bind = "127.0.0.1:${toString iocainePort}";
              mode = "http";
              use = {
                handler-from = "main";
                metrics = "metrics";
              };
            };
          };
        };
      };

      services.nginx.commonHttpConfig = ''
        map $request_method $blog_upstream_location {
          GET      http://127.0.0.1:${toString iocainePort};
          HEAD     http://127.0.0.1:${toString iocainePort};
          default  http://127.0.0.1:${toString port};
        }
      '';

      services.nginx.virtualHosts."${domain}" = {
        enableACME = true;
        forceSSL = true;

        extraConfig = ''
          client_max_body_size 512M;
          recursive_error_pages on;
        '';

        serverAliases = [ "testing.${domain}" ];

        locations."/" = {
          proxyPass = "$blog_upstream_location";
          extraConfig = ''
            proxy_cache off;
            proxy_intercept_errors on;
            proxy_pass_header Server;
            error_page 421 = @git-pages;
          '';
        };

        locations."@git-pages" = {
          proxyPass = "http://localhost:${toString port}";
          extraConfig = ''
            ssi on;
            proxy_cache off;
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
            error_page 404 /404;
          '';
        };
      };
    };
}
