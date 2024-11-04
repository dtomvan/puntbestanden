args @ { pkgs ? import "<nixpkgs>" {}, ... }:
let 
# HACK: Path fuckery
getShell = path: {
	name = builtins.elemAt (builtins.match "(${builtins.toString ./.})/(.+)(.nix)" "${builtins.toString path}") 1;
	value = (pkgs.callPackage path args).default;
};
getShells = paths: let
	shells = pkgs.lib.lists.forEach paths getShell;
	in (builtins.listToAttrs shells) // { default = (builtins.head shells).value; };
in (getShells [
	./install.nix
	./iso.nix
])
