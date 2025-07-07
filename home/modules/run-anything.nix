# completely graphical wrapper around nix run
{
  inputs,
  host,
  pkgs,
  lib,
  ...
}:
let
  # this is basically just pkgs/by-name but takes a hell lot time and effort
  # than grabbing them recursively with `nix search`/`nix-env`
  pkgsAttrs = lib.pipe pkgs [
    builtins.attrNames
    lib.concatLines
    (builtins.toFile "nixpkgs-attrs-0-unstable-${inputs.nixpkgs.lastModifiedDate}")
  ];
  mkRunAnything =
    selectprog:
    pkgs.writeShellApplication {
      name = "run-anything";
      runtimeInputs = [ pkgs.parallel ];
      text = ''
        ${lib.getExe selectprog} < ${pkgsAttrs} \
        | parallel --will-cite nix run nixpkgs#{}
      '';
    };
in
{
  xdg.desktopEntries.run-anything = lib.mkIf host.os.isGraphical {
    name = "Run Anything";
    comment = "nix run nixpkgs#...";
    exec = lib.getExe (mkRunAnything pkgs.tofi);
  };

  home.packages = [ (mkRunAnything pkgs.skim) ];
}
