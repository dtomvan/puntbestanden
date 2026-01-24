{
  inputs,
  ...
}:
{
  config = {
    flake-file.inputs = {
      sops = {
        url = "github:Mic92/sops-nix";
        inputs.nixpkgs.follows = "nixpkgs";
      };
    };

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
        devshells.default.packages = with pkgs; [
          age
          sops
          ssh-to-age
        ];
      };
  };
}
