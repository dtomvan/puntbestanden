{
  perSystem =
    { pkgs, ... }:
    {
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
        pkgs.runCommand "my-jorge-blog" { nativeBuildInputs = [ pkgs.nur.repos.dtomvan.jorge ]; }
          ''
            cp -r ${./.}/* .
            chmod -R +w *
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
