{ self, lib, ... }:
{
  # TODO: not put this under kvm
  flake.modules.nixos.virt-kvm =
    { config, ... }:
    let
      host = self.lib.getHost {
        inherit config;
        module = "virt-kvm/nat";
      };
    in
    {
      networking.nat = {
        enable = true;
        # Use "ve-*" when using nftables instead of iptables
        internalInterfaces = [ "ve-+" ];
        # TODO: update for other machines if needed
        externalInterface = lib.mkIf (host ? wirelessInterface) host.wirelessInterface;
        # Lazy IPv6 connectivity for the container
        enableIPv6 = true;
      };
    };
}
