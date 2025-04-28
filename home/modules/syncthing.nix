{ pkgs, ... }:
let
  syncthing-shortcut = pkgs.makeDesktopItem {
    name = "syncthing";
    desktopName = "Syncthing";
    comment = "Open syncthing in browser";
    icon = "Syncthing";
    exec = "${pkgs.xdg-utils}/bin/xdg-open http://127.0.0.1:8384/";
    categories = [ "Utility" ];
  };
in
{
  home.packages = [ syncthing-shortcut ];
}
