# WARNING: plasma theming might break, so don't use with profiles-plasma, I guess
{ self, ... }:
{
  flake.modules.nixos.profiles-dank =
    { lib, ... }:
    {
      imports = with self.modules.nixos; [ profiles-mangowc ];

      programs.niri.enable = true;

      services.displayManager = {
        dms-greeter = {
          enable = true;
          compositor.name = "niri";
        };
        sddm.enable = lib.mkForce false;
        sddm.wayland.enable = lib.mkForce false;
        gdm.enable = lib.mkForce false;
      };

      programs.dms-shell.enable = true;

      # so dms can write its configs for qt apps
      qt = {
        enable = true;
        platformTheme = "qt5ct"; # also does qt6ct
        style = lib.mkForce null; # so qt5ct can be overridden by dms
      };
    };

  flake.modules.homeManager.profiles-dank =
    {
      self',
      pkgs,
      lib,
      ...
    }:
    {
      imports = with self.modules.homeManager; [ profiles-mangowc ];

      services.swww.enable = lib.mkForce false;
      wayland.windowManager.mango = {
        # override all bars and notification daemons etc.
        autostart_sh = lib.mkForce ''
          dms run &
          { sleep 5; dms ipc call wallpaper set ${self'.packages.my-wallpaper.passthru.kdeFilePath}; } &
          if [ $(hostname) == feather ]; then
            ${pkgs.wlr-randr}/bin/wlr-randr --output eDP-1 --scale 1.25
          fi
          # TODO: remove this when dank/QS supports checking for idle
          ${lib.getExe (self'.legacyPackages.hypridleOf "dms ipc call lock lock")} &
        '';
      };

      # used for when the tony mangowc config is used
      xdg.configFile."mango/snip.sh".source = lib.mkForce (
        pkgs.writeShellScript "dank-snip.sh" "${pkgs.dms-shell}/bin/dms screenshot"
      );

      # let DMS manage GTK themes
      gtk.enable = lib.mkForce false;
    };
}
