# used to make a fake firefox wrapper so for example devedition is happy with
# my "normal" firefox profile...
{ self, ... }:
{
  flake.modules.homeManager.firefox =
    { pkgs, lib, ... }:
    let
      inherit (pkgs.stdenv.hostPlatform) system;
    in
    {
      programs.firefox = {
        package = self.legacyPackages.${system}.makeFakeFirefox pkgs.firefox-devedition {
          args = "-P default";
        };
      };
    };
}
