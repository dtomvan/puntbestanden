{ lib, ... }:
{
  flake.modules.nixos.virt-nat =
    {
      host ? null,
      ...
    }:
    {
      networking.nat = {
        enable = true;
        # Use "ve-*" when using nftables instead of iptables
        internalInterfaces = [ "ve-+" ];
        externalInterface = lib.mkIf (
          host ? networking.wirelessInterface
        ) host.networking.wirelessInterface;
        # Lazy IPv6 connectivity for the container
        enableIPv6 = true;
      };
    };
}
