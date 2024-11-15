{pkgs ? import <nixpkgs> {}, ...}: {
  default = pkgs.mkShell {
    packages = with pkgs; [
      alejandra
      gnugrep
      findutils
      git
    ];
    shellHook = ''
      git ls-files | grep '\.nix$' | xargs alejandra
    '';
  };
}
