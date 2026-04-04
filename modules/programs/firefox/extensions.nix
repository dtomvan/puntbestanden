{
  flake.modules.homeManager.firefox =
    { pkgs, ... }:
    let
      ubo = pkgs.nur.repos.dtomvan.ublock-origin;
    in
    {
      programs.firefox.profiles.default = {
        extensions = with pkgs.nur.repos.rycee.firefox-addons; {
          packages = [
            keepassxc-browser
            sponsorblock
            dearrow
            plasma-integration

            ubo
            stylus

            enhancer-for-youtube
          ]
          ++ (with pkgs.nur.repos.dtomvan; [
            darkreader
            obsidian-web-clipper
            steam-database
          ]);

          force = true;
        };

        settings = {
          "sidebar.main.tools" = "${ubo.addonId},history,bookmarks";
          "sidebar.installed.extensions" = ubo.addonId;
        };
      };
    };
}
