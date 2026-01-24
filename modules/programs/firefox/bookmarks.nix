{
  flake.modules.homeManager.firefox.programs.firefox.profiles.default = {
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
            name = "nixpkgs pulls";
            url = "https://github.com/NixOS/nixpkgs/pulls?q=involves:dtomvan";
          }
          {
            name = "NüschtOS search";
            url = "https://search.nüschtos.de/";
          }
          {
            name = "Me on repology";
            url = "https://repology.org/maintainer/18gatenmaker6%40gmail.com";
          }
          {
            name = "Nix package versions";
            url = "https://lazamar.co.uk/nix-versions/";
          }
        ];
      }
    ];
  };
}
