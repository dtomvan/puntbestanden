{
  flake.modules.nixos.services-sane =
    { pkgs, ... }:
    {
      hardware.sane = {
        enable = true;
        extraBackends = with pkgs; [
          hplip
          ipp-usb
          sane-airscan
        ];
      };
    };
}
