{ inputs, lib, ... }:
{
  flake-file.inputs = {
    systems.url = "github:nix-systems/default";
  };
  systems = lib.subtractLists [ "x86_64-darwin" ] (import inputs.systems);
}
