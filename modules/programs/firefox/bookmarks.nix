{
  flake.modules.homeManager.firefox.programs.firefox.profiles.dev-edition-default = {
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
            name = "Add to Miniflux";
            url = "javascript:location.href='https://rss.toostveen.nl/bookmarklet?uri='+encodeURIComponent(window.location.href)";
          }
          {
            name = "Nix";
            bookmarks = [
              {
                name = "homepage";
                url = "https://nixos.org/";
              }
              {
                name = "wiki";
                url = "https://wiki.nixos.org/";
              }
              {
                name = "search";
                url = "https://search.nixos.org/";
              }
              {
                name = "status";
                url = "https://status.nixos.org/";
              }
              {
                name = "discourse";
                url = "https://discourse.nixos.org/";
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
                name = "NUR";
                url = "https://nur.nix-community.org";
              }
              {
                name = "Nix manual";
                url = "https://nix.dev/manual/nix/latest/";
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
                name = "Nixpkgs security tracker";
                url = "https://tracker.security.nixos.org/";
              }
            ];
          }
          {
            name = "infra";
            bookmarks = [
              {
                name = "fs";
                url = "https://fs.toostveen.nl";
              }
              {
                name = "rss";
                url = "https://rss.toostveen.nl";
              }
              {
                name = "grafana";
                url = "https://grafana.toostveen.nl";
              }
              {
                name = "prometheus";
                url = "https://prometheus.toostveen.nl";
              }
            ];
          }
          {
            name = "Forges";
            bookmarks = [
              {
                name = "tom";
                url = "https://git.toostveen.nl";
              }
              {
                name = "bart";
                url = "https://git.bartoostveen.nl";
              }
              {
                name = "elisaado";
                url = "https://git.elisaado.nl";
              }
              {
                name = "codeberg";
                url = "https://codeberg.org";
              }
              {
                name = "lix";
                url = "https://git.lix.systems";
              }
            ];
          }
          {
            name = "social";
            bookmarks = [
              {
                name = "toot";
                url = "https://toot.cat";
              }
              {
                name = "lobsters";
                url = "https://lobste.rs";
              }
              {
                name = "matrix";
                url = "https://app.cinny.in";
              }
            ];
          }
          {
            name = "To my students";
            url = "http://ozark.hendrix.edu/~yorgey/forest/00FD/index.xml";
          }
        ];
      }
    ];
  };
}
