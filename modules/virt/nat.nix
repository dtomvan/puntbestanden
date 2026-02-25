{ lib, ... }:
{
  # TODO: not put this under kvm
  flake.modules.nixos.virt-kvm =
    {
      host ? null,
      ...
    }:
    {
      networking.nat = {
        enable = true;
        # Use "ve-*" when using nftables instead of iptables
        internalInterfaces = [ "ve-+" ];
        externalInterface = lib.mkIf (host ? wirelessInterface) host.wirelessInterface;
        # Lazy IPv6 connectivity for the container
        enableIPv6 = true;
      };
    };
}
