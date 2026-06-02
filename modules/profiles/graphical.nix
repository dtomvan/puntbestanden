{ self, lib, ... }:
let
  inherit (lib) mkDefault mkIf;
in
{
  flake.modules = {
    nixos.profiles-graphical =
      { pkgs, ... }:
      {
        imports = builtins.attrValues {
          inherit (self.modules.nixos)
            plymouth
            hardware-sound
            fonts
            ;
        };

        programs.foot = {
          enable = true;
          xdg.serverAutostart = true;
        };

        xdg.terminal-exec = {
          enable = true;
          settings.default = [ "foot.desktop" ];
        };

        services.flatpak.enable = true;
        security.polkit.enable = true;

        environment.systemPackages = builtins.attrValues {
          inherit (pkgs)
            alsa-utils
            pavucontrol
            wl-clipboard
            ;
        };
      };

    homeManager.profiles-graphical =
      { config, pkgs, ... }:
      {
        imports = builtins.attrValues {
          inherit (self.modules.homeManager)
            firefox
            terminals
            ;
        };

        modules.terminals.foot.enable = mkDefault true;
        home.os.isGraphical = mkDefault true;

        home.pointerCursor = {
          enable = true;
          package = pkgs.kdePackages.breeze;
          name = "breeze_cursors";
          size = 24;
          gtk.enable = true;
          x11.enable = true;
          hyprcursor = mkIf config.wayland.windowManager.hyprland.enable {
            enable = true;
            size = 24;
          };
        };

        dconf.settings = {
          "org/gnome/desktop/interface" = {
            color-scheme = "prefer-dark";
          };
        };
      };
  };
}
