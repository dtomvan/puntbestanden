{
  flake.modules.nixos.hardware-elan-tp = {
    hardware.trackpoint = {
      enable = true;
      emulateWheel = true;
      device = "TPPS/2 Elan TrackPoint";
    };
  };
}
