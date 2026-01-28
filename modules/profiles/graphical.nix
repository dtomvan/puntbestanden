{ self, ... }:
let
  inherit (self.modules) homeManager;
in
{
  flake.modules = {
    nixos.profiles-graphical =
      { pkgs, ... }:
      {
        imports = with self.modules.nixos; [
          plymouth
          hardware-sound
          fonts
        ];

        environment.systemPackages = with pkgs; [
          alsa-utils
          pavucontrol
          wl-clipboard
        ];
      };

    homeManager.profiles-graphical =
      {
        config,
        lib,
        pkgs,
        ...
      }:
      {
        imports = with homeManager; [
          firefox
          terminals
        ];

        home.os.isGraphical = lib.mkDefault true;

        home.pointerCursor = {
          enable = true;
          package = pkgs.kdePackages.breeze;
          name = "Breeze";
          size = 24;
          gtk.enable = true;
          x11.enable = true;
          hyprcursor = lib.mkIf config.wayland.windowManager.hyprland.enable {
            enable = true;
            size = 24;
          };
        };

        dconf.settings = {
          "org/gnome/desktop/interface" = {
            color-scheme = "prefer-dark";
          };
        };

        modules.terminals = {
          alacritty.enable = true;
        };
      };
  };
}
