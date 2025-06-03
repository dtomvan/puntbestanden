{ lib, ... }:
with lib;
let
  keys = {
    boomer = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFkdbc1mWvIUciwrrIZVRYrZwTBmQ7Cehd/laxzzdlyL tomvd@boomer";
    feather = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICYRKHdw4dNFdV36OmEQvxEvko5fpkfV/Ch6pQypmOo8 tomvd@feather";
    kaput = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIN+tAFrOJ+6ksJJ2WcQec0xbyCEb+zYfDtLdyVTOW8Vg tomvd@kaput";
  };
  knownHosts = mapAttrs' (n: v: nameValuePair n { publicKey = v; }) keys;
in
{
  services.openssh.enable = true;
  users.users.tomvd.openssh.authorizedKeys.keys = builtins.attrValues keys;

  programs.ssh = { inherit knownHosts; };
}
