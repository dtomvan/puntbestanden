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
          ]
          ++ (with pkgs.nur.repos.dtomvan; [
            darkreader
            obsidian-web-clipper
            sidebery
            steam-database
            ublock-origin
            enhancer-for-youtube-bin
          ]);

          force = true;
        };
      };
    };
}
