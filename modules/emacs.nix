{
  flake.modules.nixos.profiles-workstation =
    { pkgs, ... }:
    {
      environment.systemPackages = [
        (pkgs.emacs-pgtk.pkgs.withPackages (
          p:
          let
            # loosely keep this in sync with whatever is in the config. {,M}ELPA exists if
            # it is missing something
            basePackages = with p; [
              beframe
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
              # treesit-langs
              typst-ts-mode
              # ultra-scroll
              undo-fu
              vertico
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
        ))
      ];
    };
}
