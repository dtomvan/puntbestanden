{
  flake.modules.homeManager.nano =
    { pkgs, lib, ... }:
    let
      mkApp =
        pkg:
        lib.pipe { inherit pkg; } [
          pkgs.lazy-app.override
          lib.getExe
        ];

      formatters = lib.mapAttrs (_n: mkApp) {
        inherit (pkgs)
          gofumpt
          jq
          nixfmt-rfc-style
          ruff
          rustfmt
          shfmt
          ;
      };
    in
    {
      home.file.".nanorc".text = ''
        extendsyntax go formatter "${formatters.gofumpt}"
        extendsyntax json formatter "${formatters.jq}" "." "-"
        extendsyntax nix formatter "${formatters.nixfmt-rfc-style}"
        extendsyntax python formatter "${formatters.ruff}"
        extendsyntax rust formatter "${formatters.rustfmt}"
        extendsyntax sh formatter "${formatters.shfmt}"
      '';
    };
}
