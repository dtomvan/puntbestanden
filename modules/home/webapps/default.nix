{ config, ... }:
{
  pkgs,
  lib,
  ...
}:
let
  importWebApp =
    n:
    let
      module = import ./${n};
      inherit (module) url;
      exec = "${lib.getExe pkgs.ungoogled-chromium} --app=${url}";
      withoutUrl = lib.removeAttrs module [ "url" ];
      withExec = withoutUrl // {
        inherit exec;
      };
    in
    withExec;
in
{
  xdg.desktopEntries = lib.pipe config.flake.modules.webApps [
    (lib.map (n: importWebApp n))
  ];
}
