{
  flake.modules.homeManager.hyprland = {
    wayland.windowManager.hyprland = {
      settings.exec-once = [ "fnott" ];
    };
  };
}
