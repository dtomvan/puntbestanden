# used to make a fake firefox wrapper so for example devedition is happy with
# my "normal" firefox profile...
{
  flake.modules.homeManager.firefox =
    { self', pkgs, ... }:
    {
      programs.firefox = {
        package = self'.legacyPackages.makeFakeFirefox pkgs.firefox-devedition {
          args = "-P default";
        };
      };
    };
}
