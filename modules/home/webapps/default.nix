{
  config,
  flake-parts-lib,
  lib,
  ...
}:
{
  # WHY is this not the default behaviour for a novel `flake.*` option? If
  # I DONT set this, it will _error out_ because it says that the option is
  # defined multiple times. At least due to these types in nixpkgs they can be
  # merged automatically </rant>
  options = {
    flake = flake-parts-lib.mkSubmoduleOptions {
      webApps = lib.mkOption {
        type = with lib.types; lazyAttrsOf raw;
        default = { };
      };
    };
  };

  config.flake.modules.homeManager.webapps =
    {
      pkgs,
      lib,
      ...
    }:
    let
      makeWebApp =
        _n: v:
        let
          exec = "${lib.getExe pkgs.ungoogled-chromium} --app=${v.url}";
          withoutUrl = lib.removeAttrs v [ "url" ];
          withExec = withoutUrl // {
            inherit exec;
          };
        in
        withExec;
    in
    {
      xdg.desktopEntries = lib.mapAttrs makeWebApp config.flake.webApps;
    };
}
