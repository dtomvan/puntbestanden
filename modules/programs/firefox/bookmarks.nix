{
  flake.modules.homeManager.firefox = {
    programs.firefox.profiles.default = {
      bookmarks.force = true;
      bookmarks.settings = [
        {
          toolbar = true;
          bookmarks = [
            {
              name = "about:config";
              url = "about:config";
            }
            {
              name = "nixpkgs";
              url = "https://github.com/NixOS/nixpkgs/";
            }
            {
              name = "NüschtOS search";
              url = "https://search.nüschtos.de/";
            }
            # {
            #   name = "NGI@NIX";
            #   toolbar = true;
            #   bookmarks = [
            # {
            #   name = "SoN 2025";
            #   url = "https://github.com/ngi-nix/summer-of-nix/";
            # }
            # {
            #   name = "ngipkgs";
            #   url = "https://github.com/ngi-nix/ngipkgs/";
            # }
            #   ];
            # }
            {
              name = "Me on repology";
              url = "https://repology.org/maintainer/18gatenmaker6%40gmail.com";
            }
            {
              name = "Revsets";
              url = "https://jj-vcs.github.io/jj/latest/revsets/";
            }
            {
              name = "unreviewed PRs to nixpkgs";
              url = "https://github.com/NixOS/nixpkgs/pulls?utf8=%E2%9C%93&q=is%3Aopen+is%3Apr+-is%3Adraft+review%3Anone+sort%3Acreated-asc+-label%3A%222.status%3A+work-in-progress%22+-label%3A%222.status%3A+merge+conflict%22";
            }
            {
              name = "Electron apps to be built from source";
              url = "https://github.com/NixOS/nixpkgs/issues/296939";
            }
            {
              name = "Nix package versions";
              url = "https://lazamar.co.uk/nix-versions/";
            }
          ];
        }
      ];
    };
  };
}
