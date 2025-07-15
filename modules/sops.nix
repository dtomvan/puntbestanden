{ inputs, ... }:
{
  flake.modules.nixos.profiles-base = {
    imports = [
      inputs.sops.nixosModules.sops
    ];

    sops.age.sshKeyPaths = [
      "/etc/ssh/ssh_host_ed25519_key"
      "/home/tomvd/.ssh/id_ed25519"
    ];
  };
}
