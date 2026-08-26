{
  # from https://github.com/bitbloxhub/nixos-config
  flake.modules.homeManager.firefox.programs.firefox.profiles.dev-edition-default.search = {
    force = true;
    engines = {
      home-manager-options = {
        definedAliases = [ "!hm" ];
        icon = "https://home-manager-options.extranix.com/images/favicon.png";
        name = "Home Manager Options";
        urls = [
          { template = "https://home-manager-options.extranix.com/?release=master&query={searchTerms}"; }
        ];
      };
      nixos-discourse = {
        definedAliases = [ "!nixosd" ];
        icon = "https://search.nixos.org/favicon-96x96.png";
        urls = [ { template = "https://discourse.nixos.org/search?q={searchTerms}"; } ];
      };
      nixos-options = {
        definedAliases = [ "!nixos" ];
        icon = "https://search.nixos.org/favicon-96x96.png";
        urls = [ { template = "https://search.nixos.org/options?channel=unstable&query={searchTerms}"; } ];
      };
      nixos-wiki = {
        definedAliases = [ "!nixosw" ];
        icon = "https://search.nixos.org/favicon-96x96.png";
        urls = [ { template = "https://wiki.nixos.org/w/index.php?search={searchTerms}"; } ];
      };
      nixpkgs = {
        definedAliases = [ "!nix" ];
        icon = "https://search.nixos.org/favicon-96x96.png";
        urls = [ { template = "https://search.nixos.org/packages?channel=unstable&query={searchTerms}"; } ];
      };
      noogle = {
        definedAliases = [ "!noogle" ];
        icon = "https://noogle.dev/favicon.png";
        name = "Noogle";
        urls = [ { template = "https://noogle.dev/q?term={searchTerms}"; } ];
      };
    };
  };
}
