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
    boomer = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMm/zcLreRp8+urjzkMpU92xO4oVRoCzn2Em/kkpTjoy tomvd@boomer";
    feather = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJ36mBHi2bPiILfqtV79sCNwj0lXP6xNZIj7bSmk8Fep tomvd@feather";
  };

  config.flake.modules.nixos.services-ssh = {
    services.openssh.enable = true;
    users.users.root.openssh.authorizedKeys.keys = builtins.attrValues config.sshKeys;
    programs.ssh = { inherit knownHosts; };
  };
}
