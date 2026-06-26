{ self, ... }:
{
  perSystem =
    { pkgs, ... }:
    let
      # nixIcon = "${pkgs.nixos-icons}/share/icons/hicolor/256x256/apps/nix-snowflake.png";
      nixIcon = pkgs.fetchurl {
        url = "https://raw.githubusercontent.com/imnotpoz/nixwebr.ing/7a074f42cce4517819085247cae0a46c06974b5d/site/nix-webring.svg";
        hash = "sha256-H9vFuKSK0ZoRLJCnEmni33vkizc9aAzpkNqpixfjK98=";
      };
    in
    {
      devShells.blog = pkgs.mkShellNoCC {
        packages = builtins.attrValues {
          inherit (pkgs) coreutils git;
          inherit (pkgs.nur.repos.dtomvan) jorge;
        };
        shellHook = ''
          pushd "$(git rev-parse --show-toplevel)/modules/services/blog"

          install -Dm600 ${nixIcon} src/assets/img/nix-webring.svg

          nohup jorge serve &
        '';
      };

      packages.blog =
        pkgs.runCommand "my-jorge-blog"
          {
            nativeBuildInputs = [ pkgs.nur.repos.dtomvan.jorge ];

            with_nix_webring = "1";
            nix_rev = if self ? sourceInfo.rev then "commit/${self.sourceInfo.rev}" else "branch/hoofdlijn";
          }
          ''
            cp -r ${./.}/* .
            chmod -R +w *
            install -Dm400 ${nixIcon} -t src/assets/img
            substituteAllInPlace layouts/default.html
            substituteAllInPlace layouts/post.html
            substituteAllInPlace src/index.html
            jorge build
            cp -r target $out
          '';
    };

  flake.modules.nixos.services-blog =
    { self', config, ... }:
    let
      inherit (import ../../_consts.nix) domain;
    in
    {
      imports = [ self.modules.nixos.services-tyck ];

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

      services.nginx.virtualHosts."${domain}" = {
        enableACME = true;
        forceSSL = true;

        locations."/".root = self'.packages.blog;
      };
    };
}
