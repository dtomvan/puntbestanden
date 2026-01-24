{
  flake.modules.nixos.services-sane =
    { pkgs, ... }:
    {
      hardware.sane = {
        enable = true;
        extraBackends = with pkgs; [
          hplip
          sane-airscan
          ipp-usb
        ];
      };
    };
}
