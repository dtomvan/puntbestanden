{pkgs ? import <nixpkgs> {}, ...}: {
  default = pkgs.mkShell {
    packages = with pkgs; [
      nurl
	  nix-init
    ];
  };
}
