{
  flake.modules.nixos.networking-tailscale = {
    services.tailscale = {
      enable = true;
      openFirewall = true;
    };
  };
}
