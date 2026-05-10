{
  flake.modules.homeManager.firefox =
    { pkgs, ... }:
    {
      programs.firefox.profiles.default = {
        extensions = {
          packages = builtins.attrValues {
            inherit (pkgs.nur.repos.rycee.firefox-addons)
              dearrow
              enhancer-for-youtube
              keepassxc-browser
              plasma-integration
              sponsorblock
              stylus
              ;
            inherit (pkgs.nur.repos.dtomvan)
              darkreader
              obsidian-web-clipper
              steam-database
              ublock-origin
              ;
          };

          force = true;
        };

        settings =
          let
            inherit (pkgs.nur.repos.dtomvan.ublock-origin) addonId;
          in
          {
            "sidebar.main.tools" = "${addonId},history,bookmarks";
            "sidebar.installed.extensions" = addonId;
          };
      };
    };
}
