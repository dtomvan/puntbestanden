{
  inputs,
  host,
}:
if inputs.nixpkgs.lib.strings.hasInfix "linux" host.system then
  [
    inputs.nixvim.homeManagerModules.nixvim
    inputs.plasma-manager.homeManagerModules.plasma-manager
    ./common.nix
    ./hosts/${host.hostName}.nix

    modules/basic-cli.nix
    modules/helix.nix
  ]
  ++ inputs.nixpkgs.lib.optionals host.os.isGraphical [
    modules/firefox.nix
    modules/terminals
    modules/syncthing.nix
    modules/lisp.nix
  ]
  ++ inputs.nixpkgs.lib.optional host.os.wantsKde modules/plasma
else
  [ ]
