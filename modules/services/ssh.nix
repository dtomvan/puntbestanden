{ lib, config, ... }:
let
  inherit (lib)
    mapAttrs'
    mkOption
    nameValuePair
    ;

  inherit (lib.types)
    attrsOf
    str
    ;

  knownHosts = mapAttrs' (n: v: nameValuePair n { publicKey = v; }) config.sshKeys;
in
{
  # TASK(20260225-225945): per-user and/or less "global"?
  options.sshKeys = mkOption {
    type = attrsOf str;
    default = { };
  };

  config.sshKeys = {
    boomer = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIL8M2MZ3h6AGyUGmzIY5AG0nRYvh6DOAE4TbEmfSefdt tomvd@boomer";
    feather = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILfGy4zOT23WZZX+8smSqFd1BFFrS2afwsYNfdgSDXh8 tomvd@feather";
  };

  config.flake.modules.nixos.services-ssh = {
    services.openssh.enable = true;
    users.users.root.openssh.authorizedKeys.keys = builtins.attrValues config.sshKeys;
    programs.ssh = { inherit knownHosts; };
  };
}
