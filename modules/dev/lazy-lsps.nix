{
  # used in both helix and neovim
  # if you add/remove anything here, helix will pick it up no problem
  # automatically. Please update the neovim lspconfig block accordingly.
  perSystem =
    { inputs', pkgs, ... }:
    {
      packages.lazyLsps = pkgs.symlinkJoin {
        name = "lazy-language-servers";
        paths = map inputs'.lazy-apps.packages.lazy-app.override [
          { pkg = pkgs.bash-language-server; }
          {
            pkg = pkgs.clang-tools;
            exe = "clangd";
          }
          { pkg = pkgs.cmake-language-server; }
          { pkg = pkgs.dockerfile-language-server; }
          { pkg = pkgs.emmet-language-server; }
          { pkg = pkgs.kotlin-language-server; }
          {
            pkg = pkgs.pyright;
            exe = "pyright-langserver";
          }
          { pkg = pkgs.ruff; }
          { pkg = pkgs.rust-analyzer; }
          { pkg = pkgs.rustfmt; }
          { pkg = pkgs.svelte-language-server; }
          { pkg = pkgs.taplo; }
          { pkg = pkgs.terraform-ls; }
          { pkg = pkgs.yaml-language-server; }
        ];
      };
    };
}
