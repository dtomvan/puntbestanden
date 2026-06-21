{
  pkgs-overlays = [
    (_final: prev: {
      matrix-continuwuity = prev.matrix-continuwuity.overrideAttrs (
        finalAttrs: _: {
          version = "0.5.10";
          src = prev.fetchFromGitea {
            domain = "forgejo.ellis.link";
            owner = "continuwuation";
            repo = "continuwuity";
            tag = "v0.5.10";
            hash = "sha256-oevEGYlAK/rMJhm200CkwerT5oVak8sJj0Fa6r6+J/Q=";
          };
          cargoHash = null;
          cargoDeps = prev.rustPlatform.fetchCargoVendor {
            inherit (prev.matrix-continuwuity) pname;
            inherit (finalAttrs) version src;
            hash = "sha256-uvMiFURXxkLbbbwq4pG5hevsLZHQ1wVfTNvzQRTQWxE=";
          };
        }
      );
    })
  ];
}
