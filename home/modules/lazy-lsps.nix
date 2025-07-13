# used in both helix and neovim
# if you add/remove anything here, helix will pick it up no problem
# automatically. Please update the neovim lspconfig block accordingly.
{ pkgs }:
pkgs.symlinkJoin {
  name = "lazy-language-servers";
  paths =
    with pkgs;
    map lazy-app.override [
      { pkg = bash-language-server; }
      {
        pkg = clang-tools;
        exe = "clangd";
      }
      { pkg = cmake-language-server; }
      { pkg = dockerfile-language-server-nodejs; }
      { pkg = emmet-language-server; }
      { pkg = kotlin-language-server; }
      {
        pkg = pyright;
        exe = "pyright-langserver";
      }
      { pkg = ruff; }
      { pkg = rust-analyzer; }
      { pkg = rustfmt; }
      { pkg = svelte-language-server; }
      { pkg = taplo; }
      { pkg = terraform-ls; }
      { pkg = yaml-language-server; }
    ];
}
