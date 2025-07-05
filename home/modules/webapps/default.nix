{
  pkgs,
  lib,
  host,
  ...
}:
let
  appNames = [
    "arch/packages.nix"
    "arch/wiki.nix"
    "excalidraw"
    "github"
    "gitlab"
    "nixos/discourse.nix"
    "nixos/search.nix"
    "noogle"
    "toot-cat"
  ];

  sanitizeAppName = lib.replaceStrings [ "/" ] [ "-" ];

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
  xdg.desktopEntries = lib.pipe appNames [
    (lib.map (n: lib.nameValuePair (sanitizeAppName n) (importWebApp n)))
    lib.listToAttrs
    (lib.mkIf host.os.isGraphical)
  ];
}
