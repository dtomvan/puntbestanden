{
  inputs,
  host,
}:
[
  inputs.nixvim.homeManagerModules.nixvim
  inputs.dont-track-me.homeManagerModules.default
  ./common.nix
  ./${host.hostName}.nix

  modules/basic-cli.nix
  modules/helix.nix
  modules/tools.nix
]
++ inputs.nixpkgs.lib.optionals host.os.isGraphical [
  modules/firefox.nix
  modules/terminals
  modules/syncthing.nix
  modules/lisp.nix
]
