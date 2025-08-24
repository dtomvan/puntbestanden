{ config, inputs, ... }:
{
  flake-file.inputs = {
    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  imports = [ inputs.nixvim.flakeModules.default ];

  nixvim = {
    packages.enable = true;
    checks.enable = true;
  };

  perSystem =
    {
      self',
      pkgs,
      lib,
      system,
      ...
    }:
    {
      nixvimConfigurations = {
        nixvim = inputs.nixvim.lib.evalNixvim {
          inherit system;
          modules = [
            config.flake.modules.nixvim.default
            { nixpkgs = { inherit pkgs; }; }
          ];
        };
      };

      apps.nixvim-activate = {
        type = "app";
        meta.description = "Activate your Nixvim configuration";
        program = lib.getExe (
          pkgs.writeShellApplication {
            name = "nixvim-activate";
            runtimeInputs = with pkgs; [
              nix
              jq
            ];
            runtimeEnv = {
              NIX_CONFIG = "extra-experimental-features = nix-command flakes";
              # saves a whole lotta time
              nixvimTarget = self'.packages.nixvim.overrideAttrs { dontFixup = true; };
            };
            text = ''
              if nix profile list --json | jq -e '.elements.nixvim' >/dev/null; then
                echo removing existing nixvim install...
                nix profile remove nixvim
              fi

              echo installing new nixvim install...
              nix profile install "''${nixvimTarget:?}"

              echo "done"
            '';
          }
        );
      };
    };

  # unused; if you enable this you get 12 seconds of eval time for free.
  # I don't think so cowboy.
  flake.modules.homeManager.nixvim =
    { self', ... }:
    {
      home.packages = [ self'.packages.nixvim ];
      systemd.user.settings.Manager.DefaultEnvironment = {
        EDITOR = "nvim";
      };
      programs.bash.shellAliases.vim = "nvim";
    };
}
