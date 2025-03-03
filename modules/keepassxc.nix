{
  pkgs,
  lib,
  hostname,
  config,
  ...
}: let
in {
  home.packages = [pkgs.keepassxc];

  # age.secrets.keeshare.file = ../secrets/keeshare.age;
  #
  xdg.configFile."keepassxc/keepassxc.ini".text = ''
    	[General]
    ConfigVersion=2
    MinimizeAfterUnlock=true
    MinimizeOnOpenUrl=true

    [Browser]
    CustomProxyLocation=
    Enabled=true

    [GUI]
    ApplicationTheme=classic
    MinimizeOnClose=true
    MinimizeOnStartup=true
    MinimizeToTray=true
    ShowTrayIcon=true
    TrayIconAppearance=monochrome-light

    [KeeShare]
    Active="<?xml version=\"1.0\"?><KeeShare><Active><Import/><Export/></Active></KeeShare>\n"
    Own="$PRIVKEY"
    QuietSuccess=true
  '';

  xdg.desktopEntries."org.keepassxc.KeePassXC" = {
    name = "KeePassXC";
    exec = "keepassxc";
    mimeType = ["application/x-keepass2"];
    categories = ["Utility" "Security"];
    icon = "keepassxc";
    startupNotify = true;
    terminal = false;
    settings = {
      SingleMainWindow = "true";
      X-GNOME-SingleWindow = "true";
    };
  };
}
