{ inputs, ... }:
{
  flake-file.inputs = {
    localsend-rs = {
      # private
      url = "github:dtomvan/localsend-rust-impl";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  text.readme.parts.localsend_rs =
    # markdown
    ''
      ## For myself: How to bootstrap `localsend-rs` inside of the flake

      - Have one of the private keys corresponding to a pubkey listed in `.sops.yaml`
        in `~/.config/sops/age/keys.txt`.
      - Enter the devshell (or nix-shell -p sops nh)
      - `nix flake lock --extra-access-tokens "$(sops decrypt secrets/localsend-rs.secret | awk '{print $3}')"`
      - `nh os switch`

      Afterwards, through the nixos module, the secret will get loaded into
      `nix.conf` and you can `nix flake update` for example without any manual setup
    '';

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
