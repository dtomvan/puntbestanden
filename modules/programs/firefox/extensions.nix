{
  flake.modules.homeManager.firefox =
    { inputs', ... }:
    {
      programs.firefox.profiles.default = {
        extensions = {
          packages = builtins.attrValues {
            inherit (inputs'.nur.legacyPackages.repos.rycee.firefox-addons)
              dearrow
              enhancer-for-youtube
              keepassxc-browser
              plasma-integration
              sponsorblock
              stylus
              ;
            inherit (inputs'.nur.legacyPackages.repos.dtomvan)
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
            inherit (inputs'.nur.legacyPackages.repos.dtomvan.ublock-origin) addonId;
          in
          {
            "sidebar.main.tools" = "${addonId},history,bookmarks";
            "sidebar.installed.extensions" = addonId;
          };
      };
    };
}
