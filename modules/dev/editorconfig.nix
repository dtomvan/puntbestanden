let
  settings = {
    "*.nix" = {
      indent_style = "space";
      indent_size = 2;
    };
  };
in
{
  flake.modules.homeManager.profiles-base = {
    editorconfig = {
      enable = true;
      inherit settings;
    };
  };

  # sync the editorconfig to this tree.
  perSystem =
    { pkgs, ... }:
    {
      files.files = [
        {
          path_ = ".editorconfig";
          drv = (pkgs.formats.ini { }).generate ".editorconfig" settings;
        }
      ];
    };
}
