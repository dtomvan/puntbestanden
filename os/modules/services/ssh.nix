{ lib, ... }:
let
  keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFkdbc1mWvIUciwrrIZVRYrZwTBmQ7Cehd/laxzzdlyL tomvd@boomer"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICYRKHdw4dNFdV36OmEQvxEvko5fpkfV/Ch6pQypmOo8 tomvd@feather"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIN+tAFrOJ+6ksJJ2WcQec0xbyCEb+zYfDtLdyVTOW8Vg tomvd@kaput"
  ];
in
{
  config = {
    services.openssh.enable = true;
    users.users.tomvd.openssh.authorizedKeys.keys = keys;
    users.users.root.openssh.authorizedKeys.keys = keys;
  };
}
