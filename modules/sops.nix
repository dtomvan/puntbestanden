{
  inputs,
  ...
}:
{
  config = {
    flake-inputs.sops = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # HACK: workaround go pin for sops-nix
    pkgs-overlays = [ (_final: prev: { buildGo125Module = prev.buildGoModule; }) ];

    flake.modules.nixos.sops = {
      imports = [
        inputs.sops.nixosModules.sops
      ];

      sops.age.sshKeyPaths = [
        "/etc/ssh/ssh_host_ed25519_key"
        "/home/tomvd/.ssh/id_ed25519"
      ];
    };

    perSystem =
      { pkgs, ... }:
      {
        devshells.default.packages = builtins.attrValues {
          inherit (pkgs)
            age
            sops
            ssh-to-age
            ;
        };
      };
  };
}
