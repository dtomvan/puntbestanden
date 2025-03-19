{pkgs, lib, ...}: {
  programs.nixvim.plugins.conjure.enable = true;
  programs.nixvim.plugins.lsp.servers.clojure_lsp.enable = true;

  programs.nixvim.extraPlugins = [
    (pkgs.vimUtils.buildVimPlugin {
      name = "vim-jack-in";
      src = pkgs.fetchFromGitHub {
        owner = "clojure-vim";
        repo = "vim-jack-in";
        rev = "45e5293cff0802a51dbed31a9b0141b0f80e2952";
        hash = "sha256-4kYY0jUv5U2i+G/29vPOZHqUX/cEQTWBo9pghRg9gIw=";
      };
    })
  ];

  home.packages = with pkgs; [
    clojure
    clojure-lsp
  ];
}
