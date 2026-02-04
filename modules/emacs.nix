{
  perSystem =
    {
      self',
      pkgs,
      lib,
      ...
    }:
    let
      default_el = builtins.toFile "default.el" ''
        (org-babel-load-file (locate-user-emacs-file "config.org"))
      '';
    in
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
              eat
              elfeed
              elfeed-org
              envrc
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
              undo-tree
              vc-jj
              vertico
            ]
            ++ (with pkgs; [
              # used for cloning various packages if needed
              git
            ])
            # TASK(20260204-235041): add more langs
            ++ lib.map (l: pkgs.tree-sitter-grammars."tree-sitter-${l}") [
              "elisp"
              "markdown"
              "typst"
            ];

          # the "sensible default" of loading ~/.config/emacs/config.org
          default = p.trivialBuild {
            pname = "default";
            src = default_el;
            version = "0.1.0";
            packageRequires = basePackages;
          };
        in
        basePackages ++ [ default ]
      );

      checks.emacsLoadCheck =
        pkgs.runCommandLocal "emacs-load-check"
          {
            nativeBuildInputs = [ self'.packages.myEmacs ];
          }
          ''
            HOME="$(mktemp -d)"
            cd "$HOME"
            install -Dm444 ${../stow/emacs-new/dot-config/emacs}/config.org -t ~/.config/emacs/
            emacs -x ${default_el} 2>&1 | awk -v IGNORECASE=1 '/^error/{print "Error while loading emacs config:", $0; exit 1} {print $0}'
            touch $out
          '';
    };

  flake.modules.nixos.profiles-workstation =
    { self', ... }:
    {
      environment.systemPackages = [ self'.packages.myEmacs ];
    };

  flake.modules.homeManager.profiles-workstation = {
    programs.bash.initExtra = # bash
      ''
        if [ -n "$EAT_SHELL_INTEGRATION_DIR" ]; then
          source "$EAT_SHELL_INTEGRATION_DIR/bash"
        fi
      '';
  };
}
