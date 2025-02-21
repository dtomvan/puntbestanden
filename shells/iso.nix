{pkgs ? import <nixpkgs> {}, ...}: {
  default = pkgs.mkShell {
    NIX_CONFIG = ''
      extra-experimental-features = nix-command flakes
      max-jobs = auto'';

    buildInputs = with pkgs; [
      nix
      git
      nixos-generators
    ];
    shellHook = ''
      echo nixos-generate -f iso --flake .#iso -o result-iso
    '';
  };
}
