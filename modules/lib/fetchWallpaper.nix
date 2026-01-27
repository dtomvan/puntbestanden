{
  perSystem =
    { pkgs, lib, ... }:
    {
      legacyPackages.fetchWallpaper = lib.makeOverridable (
        params@{
          url ? null,
          hash ? null,
          ...
        }:
        # hack to workaround unused args
        assert url != null && hash != null;
        let
          pkg = pkgs.fetchurl params;
        in
        pkg
        // {
          passthru = (pkg.passthru or { }) // {
            kdeFilePath = "${pkg}";
          };
        }
      );
    };
}
