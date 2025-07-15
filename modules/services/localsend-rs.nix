{ inputs, ... }:
{
  flake-file.inputs = {
    localsend-rs = {
      # private
      url = "github:dtomvan/localsend-rust-impl";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  flake.modules.nixos.services-localsend-rs =
    {
      config,
      lib,
      ...
    }:
    let
      cfg = config.services.localsend-rs;
    in
    {
      imports = [
        inputs.localsend-rs.nixosModules.localsend-rs
      ];

      options.services.localsend-rs.sopsBootstrap = lib.mkEnableOption "only setup nix and sops, don't try to fetch localsend-rs yet";

      config = {
        services.localsend-rs = lib.mkIf (!cfg.sopsBootstrap) {
          enable = lib.mkDefault true;
          user = "tomvd";
        };

        # to access the repo
        nix = {
          extraOptions = ''
            !include ${config.sops.secrets.localsend-rs.path}
          '';
        };

        sops.secrets.localsend-rs = {
          mode = "0440";
          sopsFile = ../../secrets/localsend-rs.secret;
          format = "binary";
          owner = "tomvd";
          group = "users";
        };
      };
    };
}
