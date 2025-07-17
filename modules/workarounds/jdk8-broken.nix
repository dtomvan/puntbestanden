{
  pkgs-overlays = [
    # See: https://github.com/NixOS/nixpkgs/issues/425323
    (final: _prev: {
      jdk8 = final.temurin-bin-8;
    })
  ];
}
