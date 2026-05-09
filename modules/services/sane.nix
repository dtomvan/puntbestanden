{
  flake.modules.nixos.services-sane =
    { pkgs, ... }:
    {
      hardware.sane = {
        enable = true;
        extraBackends = builtins.attrValues {
          inherit (pkgs)
            hplip
            ipp-usb
            sane-airscan
            ;
        };
      };
    };
}
