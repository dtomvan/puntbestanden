{ inputs, ... }:
{
  flake-inputs.nixocaine = {
    url = "git+https://git.madhouse-project.org/iocaine/nixocaine/?ref=stable";
    inputs.nixpkgs.follows = "nixpkgs";
    inputs.pre-commit-hooks.follows = "";
    inputs.treefmt-nix.follows = "";
  };

  flake.modules.nixos.services-iocaine =
    {
      pkgs,
      lib,
      inputs',
      ...
    }:
    let
      nsoePackage = inputs'.nixocaine.packages.nam-shub-of-enki.overrideAttrs {
        patches = [
          ./iocaine/0001-Add-contact-details.patch
        ];
      };
    in
    {
      imports = [ inputs.nixocaine.nixosModules.default ];

      services.iocaine.config = {
        # very random, yes
        initial-seed-file = "/run/current-system/boot.json";

        handler.main = {
          path = "${nsoePackage}";
          config = {
            inherits = "recommended";
            logging.classification.enable = true;
            sources = {
              wordlists =
                pkgs.fetchurl {
                  url = "https://cgit.git.savannah.gnu.org/cgit/miscfiles.git/plain/web2?id=fc51530ea66019efba9e961578df986a950cbb65";
                  hash = "sha256-KSmJWrP+x4xpY+vly7NJP+T8nhHroJWlInh7ivxTqGM=";
                }
                |> lib.singleton;

              training-corpus = [
                (pkgs.fetchurl {
                  url = "https://archive.org/download/GeorgeOrwells1984/1984_djvu.txt";
                  hash = "sha256-9R1PTa8yDtkfH+4rU5BF62ee73irhd3VYX1QB5KU+ZU=";
                })
                (pkgs.fetchurl {
                  url = "https://archive.org/download/ost-english-brave_new_world_aldous_huxley/Brave_New_World_Aldous_Huxley_djvu.txt";
                  hash = "sha256-6WkaO/3zQIezGzJDp4QjglikiTZTxgo0P4MEff2mdcY=";
                })
              ];
            };
            checks = {
              anti_robots_txt.enable = true; # blocklist for specific bots that are known to not respect your robots.txt
              browser_verification.enable = false; # seems to trip up some old browsers, and also vivaldi
              commercial_scrapers.enable = true;
              cookie_monster = {
                enable = true;
                forgejo_challenge = "automatic";
              };
              firefox_ai.enable = true; # no thanks
              generated_urls = {
                enable = true;
                identifiers = [ "clanker_mode" ]; # default is a dot, which isn't a good idea
              };
            };
          };
        };
      };
    };
}
