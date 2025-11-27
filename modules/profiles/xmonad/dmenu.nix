{
  perSystem =
    { pkgs, ... }:
    {
      packages.myDmenu = pkgs.dmenu.override {
        conf =
          # c
          ''
            static int topbar = 1;
            static int fuzzy  = 1;
            static const char *fonts[] = {
              "monospace:size=12"
            };
            static const char *prompt = NULL;
            static const char *colors[SchemeLast][2] = {
              [SchemeNorm] = { "#ebdbb2", "#282828" },
              [SchemeSel] = { "#ebdbb2", "#98971a" },
              [SchemeOut] = { "#ebdbb2", "#8ec07c" },
            };
            static unsigned int lines = 0;
            static const char worddelimiters[] = " ";
          '';
        patches = [
          (pkgs.fetchpatch2 {
            url = "https://tools.suckless.org/dmenu/patches/fuzzymatch/dmenu-fuzzymatch-5.3.diff";
            hash = "sha256-GaKjI4pGf7PRMh4VJE6l/jQK99fW8YU5ZGpgjktzaic=";
          })
        ];
      };
    };
}
