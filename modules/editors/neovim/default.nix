{ self, inputs, ... }:
{
  flake-file.inputs = {
    nixvim = {
      url = "github:nix-community/nixvim/nixos-25.11";
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
            self.modules.nixvim.default
            { nixpkgs = { inherit pkgs; }; }
          ];
        };
      };

      packages.activatable-nixvim = self'.legacyPackages.activationPackage {
        # saves a whole lotta time
        profile = self'.packages.nixvim.overrideAttrs { dontFixup = true; };
        profileName = "nixvim";
      };

      apps.nixvim-activate = {
        type = "app";
        meta.description = "Activate your Nixvim configuration";
        program = lib.getExe' self'.packages.activatable-nixvim "activate";
      };
    };

  # unused; if you enable this you get 12 seconds of eval time for free.
  # I don't think so cowboy.
  flake.modules.homeManager.nixvim =
    { pkgs, ... }:
    {
      home.packages = [ self.packages.${pkgs.hostPlatform.system}.nixvim ];
      systemd.user.settings.Manager.DefaultEnvironment = {
        EDITOR = "nvim";
      };
      programs.bash.shellAliases.vim = "nvim";
    };
}
