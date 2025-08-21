{
  flake.modules.homeManager.firefox =
    { pkgs, ... }:
    {
      programs.firefox.profiles.default = {
        extensions = with pkgs.nur.repos.rycee.firefox-addons; {
          packages = [
            keepassxc-browser
            sponsorblock
            dearrow
            plasma-integration
            # TODO: replace with NUR package
            # enhancer-for-youtube # unfree, cannot build from source :(
          ]
          ++ (with pkgs.nur.repos.dtomvan; [
            darkreader
            obsidian-web-clipper
            sidebery
            steam-database
            ublock-origin
          ]);

          force = true;
        };
      };
    };
}
