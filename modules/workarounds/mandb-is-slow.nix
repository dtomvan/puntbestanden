# https://github.com/NixOS/nixpkgs/issues/513348
{
  flake.modules.nixos.profiles-base.documentation.man = {
    mandoc.enable = true;
    man-db.enable = false;
  };
}
