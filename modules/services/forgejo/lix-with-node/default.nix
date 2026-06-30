{
  perSystem =
    {
      self',
      pkgs,
      lib,
      ...
    }:
    let
      name = "git.toostveen.nl/tom/lix-with-node";
      tag = pkgs.lixPackageSets.latest.lix.version;
    in
    {
      packages.lix-with-node = pkgs.callPackage ./_docker.nix {
        inherit name tag pkgs;
        nix = pkgs.lixPackageSets.latest.lix;
        extraPkgs = with pkgs; [
          nodejs-slim_24
          jq
          forgejo-cli
          gnupg
        ];
        nixConf.extra-experimental-features = [
          "nix-command"
          "flakes"
          "pipe-operator"
          "pipe-operators"
        ];
        bundleNixpkgs = false;
        Labels = {
          "org.opencontainers.image.title" = "Lix with NodeJS";
          "org.opencontainers.image.source" = "https://lix.systems";
          "org.opencontainers.image.vendor" = "Tom Oostveen";
          "org.opencontainers.image.version" = pkgs.lixPackageSets.latest.lix.version;
          "org.opencontainers.image.description" = "Nix container image";
        };
        flake-registry = ./custom-flake-registry.json;
      };

      packages.push-images = pkgs.writeShellApplication {
        name = "push-images";
        runtimeInputs = with pkgs; [ podman ];
        derivationArgs = {
          preferLocalBuild = true;
          allowSubstitutes = false;
        };

        text = ''
          images=(
            ${
              [
                self'.packages.lix-with-node
                self'.packages.jorge-image
              ]
              |> lib.escapeShellArgs
            }
          )
          for image in "''${images[@]}"; do
            "$image" | podman load
          done

          podman tag git.toostveen.nl/tom/lix-with-node:${lib.escapeShellArg tag} git.toostveen.nl/tom/lix-with-node:latest

          if login="$(podman login --get-login git.toostveen.nl)" && [ "$login" = tom ]; then
            urls=(
              git.toostveen.nl/tom/lix-with-node:latest
              git.toostveen.nl/tom/lix-with-node:${lib.escapeShellArg tag}
              git.toostveen.nl/tom/puntbestanden:jorge
            )
            for url in "''${urls[@]}"; do
              podman push "$url"
            done
          fi
        '';
      };
    };
}
