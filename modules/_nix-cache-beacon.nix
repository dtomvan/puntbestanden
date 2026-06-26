{ inputs, lib, ... }:
{
  flake-inputs.nix-cache-beacon = {
    url = "github:adisbladis/nix-cache-beacon";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  flake.modules.nixos.profiles-base = {
    imports = [ inputs.nix-cache-beacon.nixosModules.nix-cache-beacon ];

    services.nix-cache-beacon = {
      advert = {
        enable = true;
        port = 5000;
      };
      cache.enable = true;
    };

    # Make Nix aware of our local network cache
    nix.settings.substituters = lib.mkAfter [ "http://localhost:5028" ];

    services.harmonia.cache.enable = true; # Serve up local Nix store
    networking.firewall.allowedTCPPorts = [ 5000 ]; # Open firewall port for Harmonia
  };
}
