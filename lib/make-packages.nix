{
  self,
  inputs,
  system,
  nixpkgs ? inputs.nixpkgs,
}:
import nixpkgs {
  inherit system;
  config.allowUnfree = true;
  overlays = [
    inputs.nur.overlays.default
    inputs.nix4vscode.overlays.forVscode
    inputs.lazy-apps.overlays.default
    # broken
    # (_final: _prev: { nix4vscode.forOpenVsx = inputs.nix4vscode.lib.${system}.forOpenVsx; })
    (_final: _prev: self.packages.${system})
  ];
}
