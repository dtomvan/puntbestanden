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
    packages.jorge-image = self'.packages.lix-with-node.override {
      inherit name tag;
      extraPkgs = builtins.attrValues {
        inherit (pkgs.nur.repos.dtomvan) jorge;
        inherit (pkgs)
          envsubst
          moreutils
          nodejs-slim_24
          ;
      };
      Labels = {
        "org.opencontainers.image.title" = "Jorge";
        "org.opencontainers.image.source" = "https://jorge.oleano.dev";
        "org.opencontainers.image.vendor" = "Tom Oostveen";
        "org.opencontainers.image.version" = pkgs.nur.repos.dtomvan.jorge.version;
        "org.opencontainers.image.description" = "Image for the Jorge SSG";
      };
    };
  };
}
