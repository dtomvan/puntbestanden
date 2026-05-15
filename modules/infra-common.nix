# copied from bartoostveen/infra
{ lib, inputs, ... }:
{
  flake.modules.nixos.infra-common =
    { inputs', ... }:
    {
      nix = {
        channel.enable = lib.mkForce false;
        gc.automatic = lib.mkForce false;
        nixPath = [ "nixpkgs=${inputs.nixpkgs}" ];
        settings.experimental-features = [
          "nix-command"
          "flakes"
          "pipe-operators"
        ];
      };

      boot.kernelPackages = inputs'.nixos-small.legacyPackages.linuxPackages;

      networking = {
        useNetworkd = lib.mkForce true;
        firewall.enable = lib.mkForce true;
      };

      services = {
        dbus.implementation = "dbus";
        openssh.enable = lib.mkDefault true;
      };

      programs.nh = {
        enable = lib.mkDefault true;
        clean = {
          enable = true;
          extraArgs = "--keep 3 --optimise";
          dates = "weekly";
        };
      };
    };
}
