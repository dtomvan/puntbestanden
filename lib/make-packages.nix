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
    (_final: prev: {
      # https://github.com/dtomvan/puntbestanden/issues/1
      # https://github.com/NixOS/nixpkgs/pull/409162/files
      firefox-devedition-bin-unwrapped = (
        prev.firefox-devedition-bin-unwrapped.overrideAttrs {
          src = prev.fetchurl {
            url = "https://archive.mozilla.org/pub/devedition/releases/139.0b10/linux-x86_64/en-US/firefox-139.0b10.tar.xz";
            sha256 = "45c364b418befa59cbd1273a4152a31b1bca8873d8952ca1c0870c6f38a924f5";
          };
        }
      );
    })
  ];
}
