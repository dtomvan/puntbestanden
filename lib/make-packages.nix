{
  self,
  inputs,
  system,
  nixpkgs ? inputs.nixpkgs,
}:
import nixpkgs {
  inherit system;
  config = {
    allowUnfree = true;
    # for vintagestory
    permittedInsecurePackages = [
      "dotnet-runtime-7.0.20"
    ];
  };
  overlays = [
    inputs.nur.overlays.default
    inputs.nix4vscode.overlays.forVscode
    inputs.lazy-apps.overlays.default
    # broken
    # (_final: _prev: { nix4vscode.forOpenVsx = inputs.nix4vscode.lib.${system}.forOpenVsx; })
    self.overlays.plasmashell-workaround # https://github.com/NixOS/nixpkgs/issues/126590
    (_final: _prev: self.packages.${system})
  ];
}
