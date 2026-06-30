{ lib, ... }:
let
  inherit (lib) singleton;
  name = "git.toostveen.nl/tom/puntbestanden";
  tag = "jorge";
in
{
  flake.modules.nixos.services-forgejo.infra.fj.actions.extraLabels =
    singleton "jorge:docker://${name}:${tag}";

  perSystem = { pkgs, self', ... }: {
    packages.jorge-image = pkgs.dockerTools.streamLayeredImage {
      inherit name tag;
      # re-implement buildLayeredImage because you cant call buildLayeredImage
      # with a stream yourself...
      fromImage =
        let
          i = self'.packages.lix-with-node;
        in
        pkgs.runCommand "${i.name}.tar.gz" { nativeBuildInputs = [ pkgs.pigz ]; } ''
          ${i} | pigz -p$NIX_BUILD_CORES -nTR > $out
        '';

      contents = builtins.attrValues {
        inherit (pkgs.nur.repos.dtomvan) jorge;
        inherit (pkgs) envsubst moreutils;
      };
      config = {
        Cmd = [ (lib.getExe pkgs.bashInteractive) ];
        Labels = {
          "org.opencontainers.image.title" = "Jorge";
          "org.opencontainers.image.source" = "https://jorge.oleano.dev";
          "org.opencontainers.image.vendor" = "Tom Oostveen";
          "org.opencontainers.image.version" = pkgs.nur.repos.dtomvan.jorge.version;
          "org.opencontainers.image.description" = "Image for the Jorge SSG";
        };
        Env = [
          "PATH=${
            lib.concatStringsSep ":" [
              "/bin"
              "/root/.nix-profile/bin"
              "/nix/var/nix/profiles/default/bin"
              "/nix/var/nix/profiles/default/sbin"
            ]
          }"
          "MANPATH=${
            lib.concatStringsSep ":" [
              "/root/.nix-profile/share/man"
              "/nix/var/nix/profiles/default/share/man"
            ]
          }"
          "SSL_CERT_FILE=/nix/var/nix/profiles/default/etc/ssl/certs/ca-bundle.crt"
          "GIT_SSL_CAINFO=/nix/var/nix/profiles/default/etc/ssl/certs/ca-bundle.crt"
          "NIX_SSL_CERT_FILE=/nix/var/nix/profiles/default/etc/ssl/certs/ca-bundle.crt"
          "NIX_PATH=/nix/var/nix/profiles/per-user/root/channels:/root/.nix-defexpr/channels"
        ];
      };
    };
  };
}
