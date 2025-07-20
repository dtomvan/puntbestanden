{ lib, ... }:
{
  # TODO: not put this under kvm
  flake.modules.nixos.virt-kvm.networking.nat = {
    enable = true;
    # Use "ve-*" when using nftables instead of iptables
    internalInterfaces = [ "ve-+" ];
    # TODO: update for other machines if needed
    externalInterface = lib.mkDefault "wlp7s0";
    # Lazy IPv6 connectivity for the container
    enableIPv6 = true;
  };
}
