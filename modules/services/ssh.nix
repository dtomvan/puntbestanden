{
  flake.modules.nixos.services-ssh =
    { lib, ... }:
    with lib;
    let
      keys = {
        boomer = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIL8M2MZ3h6AGyUGmzIY5AG0nRYvh6DOAE4TbEmfSefdt tomvd@boomer";
        feather = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILZCTsfqR/RkuQxq4Z2Pq6PeLW/QqRQwM6JTluy34XyV tomvd@feather";
        kaput = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIN+tAFrOJ+6ksJJ2WcQec0xbyCEb+zYfDtLdyVTOW8Vg tomvd@kaput";
      };
      knownHosts = mapAttrs' (n: v: nameValuePair n { publicKey = v; }) keys;
    in
    {
      services.openssh.enable = true;
      users.users.tomvd.openssh.authorizedKeys.keys = builtins.attrValues keys;

      programs.ssh = { inherit knownHosts; };
    };
}
