{
  perSystem =
    { self', pkgs, ... }:
    {
      packages.myEmacs = pkgs.emacs-pgtk.pkgs.withPackages (
        p:
        let
          # loosely keep this in sync with whatever is in the config. {,M}ELPA exists if
          # it is missing something
          basePackages =
            with p;
            [
              beframe
              catppuccin-theme
              consult
              consult-denote
              corfu
              denote
              denote-markdown
              elfeed
              elfeed-org
              evil
              evil-collection
              evil-commentary
              evil-org
              evil-surround
              goto-chg
              magit
              marginalia
              markdown-mode
              nix-mode
              orderless
              org
              ox-typst
              tree-sitter-langs
              typst-ts-mode
              ultra-scroll
              undo-fu
              vertico
            ]
            # TODO: add more langs
            ++ lib.map (l: pkgs.tree-sitter-grammars."tree-sitter-${l}") [
              "elisp"
              "markdown"
              "typst"
            ];
        in
        basePackages
        ++ [
          # the "sensible default" of loading ~/.config/emacs/config.org
          (p.trivialBuild {
            pname = "default";
            src = pkgs.writeText "default.el" "(org-babel-load-file (locate-user-emacs-file \"config.org\"))";
            version = "0.1.0";
            packageRequires = basePackages;
          })
        ]
      );

      checks.emacsLoadCheck =
        pkgs.runCommandLocal "emacs-load-check"
          {
            nativeBuildInputs = [ self'.packages.myEmacs ];
          }
          ''
            HOME="$(mktemp -d)"
            cd "$HOME"
            install -Dm444 ${../stow/emacs-new/dot-config/emacs}/{init.el,config.org} -t ~/.config/emacs/
            emacs -x ~/.config/emacs/init.el
            touch $out
          '';
    };

  flake.modules.nixos.profiles-workstation =
    { pkgs, ... }:
    {
      environment.systemPackages = [ pkgs.myEmacs ];
    };
}
