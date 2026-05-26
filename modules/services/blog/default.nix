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

            with_nix_webring = "0";
            nix_rev = if self ? sourceInfo.rev then "commit/${self.sourceInfo.rev}" else "branch/hoofdlijn";
          }
          ''
            cp -r ${./.}/* .
            chmod -R +w *
            install -Dm400 ${nixIcon} -t src/assets/img
            substituteAllInPlace layouts/default.html
            jorge build
            cp -r target $out
          '';
    };

  flake.modules.nixos.services-blog =
    { self', ... }:
    {
      services.nginx.virtualHosts."${(import ../../_consts.nix).domain}" = {
        enableACME = true;
        forceSSL = true;

        locations."/".root = self'.packages.blog;
      };
    };
}
