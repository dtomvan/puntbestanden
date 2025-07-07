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
  };
  overlays = [
    inputs.nur.overlays.default
    inputs.nix4vscode.overlays.forVscode
    inputs.lazy-apps.overlays.default
    inputs.vs2nix.overlay
    # broken
    # (_final: _prev: { nix4vscode.forOpenVsx = inputs.nix4vscode.lib.${system}.forOpenVsx; })
    self.overlays.plasmashell-workaround # https://github.com/NixOS/nixpkgs/issues/126590
    (_final: _prev: self.packages.${system})
    (_final: _prev: {
      flake-fmt = inputs.flake-fmt.packages.${system}.default;
    })
  ];
}
