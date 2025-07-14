{
  flake.modules.nixos.hardware-sound = {
    services.pipewire = {
      enable = true;
      pulse.enable = true;
    };
  };
}
