{ pkgs, lib, ... }:
{
  xdg.desktopEntries.syncthing-shortcut = {
    name = "Syncthing";
    comment = "Open syncthing in browser";
    icon = "Syncthing";
    exec = "${lib.getExe' pkgs.xdg-utils "xdg-open"} http://127.0.0.1:8384/";
    categories = [ "Utility" ];
  };
}
