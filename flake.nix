{
  outputs =
    inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } (
      { lib, ... }:
      let
        import-tree =
          lib:
          let
            inherit (builtins)
              readDir
              attrNames
              concatMap
              ;

            listFilesRecursiveCond =
              dir: condition:
              let
                internalFunc =
                  folder:
                  let
                    contents = readDir folder;
                  in
                  concatMap (
                    filename:
                    let
                      # HACK: no dollar+bracket templating here, because that would be
                      # the only reason I would need to escape this file when copypasted
                      # in a bash heredoc, which I do in modules/top-level/flake-inputs.nix
                      subpath = "/" + folder + "/" + filename;
                      type = builtins.getAttr filename contents;
                    in
                    if condition { inherit filename type; } then
                      if type == "regular" then
                        [ subpath ]
                      else if type == "directory" then
                        internalFunc subpath
                      else
                        [ ]
                    else
                      [ ]
                  ) (attrNames contents);
              in
              internalFunc dir;

            isNixFile =
              { filename, type }:
              (lib.hasSuffix ".nix" filename || type == "directory") && !lib.hasPrefix "_" filename;
          in
          dir: (listFilesRecursiveCond dir isNixFile);
      in
      {
        imports = import-tree lib (toString ./. + "/modules");
      }
    );

  inputs = {
    "bart" = {
      "flake" = false;
      "url" = "github:bartoostveen/infra";
    };
    "catppuccin" = {
      "inputs" = {
        "nixpkgs" = {
          "follows" = "nixpkgs";
        };
      };
      "url" = "github:catppuccin/nix";
    };
    "copyparty" = {
      "inputs" = {
        "nixpkgs" = {
          "follows" = "nixpkgs";
        };
      };
      "url" = "github:9001/copyparty";
    };
    "deploy-rs" = {
      "inputs" = {
        "flake-parts" = {
          "follows" = "flake-parts";
        };
        "nixpkgs" = {
          "follows" = "nixpkgs";
        };
        "treefmt-nix" = {
          "follows" = "treefmt-nix";
        };
      };
      "url" = "git+https://git.toostveen.nl/tom/deploy-rs";
    };
    "devshell" = {
      "inputs" = {
        "nixpkgs" = {
          "follows" = "nixpkgs";
        };
      };
      "url" = "github:numtide/devshell";
    };
    "direnv-instant" = {
      "inputs" = {
        "flake-parts" = {
          "follows" = "flake-parts";
        };
        "nixpkgs" = {
          "follows" = "nixpkgs";
        };
        "treefmt-nix" = {
          "follows" = "treefmt-nix";
        };
      };
      "url" = "github:Mic92/direnv-instant";
    };
    "disko" = {
      "inputs" = {
        "nixpkgs" = {
          "follows" = "nixpkgs";
        };
      };
      "url" = "github:nix-community/disko/latest";
    };
    "flake-parts" = {
      "url" = "github:hercules-ci/flake-parts";
    };
    "home-manager" = {
      "inputs" = {
        "nixpkgs" = {
          "follows" = "nixpkgs";
        };
      };
      "url" = "github:nix-community/home-manager";
    };
    "lazy-apps" = {
      "inputs" = {
        "nixpkgs" = {
          "follows" = "nixpkgs";
        };
      };
      "url" = "git+https://git.toostveen.nl/tom/lazy-apps";
    };
    "ncro" = {
      "inputs" = {
        "nixpkgs" = {
          "follows" = "nixpkgs";
        };
      };
      "url" = "github:feel-co/ncro";
    };
    "nix-index-database" = {
      "inputs" = {
        "nixpkgs" = {
          "follows" = "nixpkgs";
        };
      };
      "url" = "github:nix-community/nix-index-database";
    };
    "nix-maid" = {
      "url" = "github:viperML/nix-maid";
    };
    "nixocaine" = {
      "inputs" = {
        "nixpkgs" = {
          "follows" = "nixpkgs";
        };
        "pre-commit-hooks" = {
          "follows" = "";
        };
        "treefmt-nix" = {
          "follows" = "";
        };
      };
      "url" = "git+https://git.madhouse-project.org/iocaine/nixocaine/?ref=stable";
    };
    "nixos-small" = {
      "url" = "github:nixos/nixpkgs/nixos-unstable-small";
    };
    "nixpkgs" = {
      "follows" = "nixpkgs-patcher/nixpkgs-patched";
    };
    "nixpkgs-patcher" = {
      "inputs" = {
        "flake-parts" = {
          "follows" = "";
        };
        "nix-patcher" = {
          "follows" = "";
        };
        "nixpkgs" = {
          "follows" = "";
        };
        "systems" = {
          "follows" = "";
        };
      };
      "url" = "github:dtomvan/nixpkgs-patcher";
    };
    "nixvim" = {
      "inputs" = {
        "flake-parts" = {
          "follows" = "flake-parts";
        };
        "nixpkgs" = {
          "follows" = "nixpkgs";
        };
      };
      "url" = "github:nix-community/nixvim";
    };
    "noctalia" = {
      "inputs" = {
        "nixpkgs" = {
          "follows" = "nixpkgs";
        };
      };
      "url" = "github:noctalia-dev/noctalia";
    };
    "noctalia-greeter" = {
      "inputs" = {
        "nixpkgs" = {
          "follows" = "nixpkgs";
        };
      };
      "url" = "github:noctalia-dev/noctalia-greeter";
    };
    "nur" = {
      "inputs" = {
        "flake-parts" = {
          "follows" = "flake-parts";
        };
        "nixpkgs" = {
          "follows" = "nixpkgs";
        };
      };
      "url" = "github:nix-community/NUR";
    };
    "sops" = {
      "inputs" = {
        "nixpkgs" = {
          "follows" = "nixpkgs";
        };
      };
      "url" = "github:Mic92/sops-nix";
    };
    "srvos" = {
      "inputs" = {
        "nixpkgs" = {
          "follows" = "nixpkgs";
        };
      };
      "url" = "github:nix-community/srvos";
    };
    "tasks" = {
      "inputs" = {
        "flake-parts" = {
          "follows" = "flake-parts";
        };
        "nixpkgs" = {
          "follows" = "nixpkgs";
        };
        "treefmt-nix" = {
          "follows" = "treefmt-nix";
        };
      };
      "url" = "git+https://git.toostveen.nl/tom/tasks.nvim";
    };
    "treefmt-nix" = {
      "inputs" = {
        "nixpkgs" = {
          "follows" = "nixpkgs";
        };
      };
      "url" = "github:numtide/treefmt-nix";
    };
  };
}
