let
  inherit (import ../_consts.nix) domain;
in
{ self, ... }:
{
  hosts.tp570 = {
    description = "The thingy I got from Matt";
    system = "x86_64-linux";
    users = [ "tomvd" ];
    networking = {
      hostName = "chonker";
      wireguard = {
        enable = true;
        ips = [
          "10.0.0.5/32"
          "fd42:42:42::5/128"
        ];
      };
    };
    # sshPubkey = {
    #   key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIsynhrBdKsxZvn15QtltUBduTkZ8PX3fq2U8aUT0fzh tomvd@commitit";
    # };
  };

  flake.modules.nixos.hosts-chonker =
    { pkgs, config, ... }:
    {
      imports = builtins.attrValues {
        inherit (self.modules.nixos)
          # keep-sorted start
          profiles-base
          # keep-sorted end
          ;
      };
    };

  flake.modules.maid."tomvd@chonker" = { pkgs, lib, ... }: {
    imports = builtins.attrValues {
      inherit (self.modules.maid)
        ;
    };
  };
}
