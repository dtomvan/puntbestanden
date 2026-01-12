# on the fence whether I can put it inside of `modules/community/`
{ lib, ... }:
{
  text.readme.parts.community_autounattend = lib.removePrefix "  " ''
    ## At home

    NEW: you can do this in YOUR repo too, with your own target config!

    Just run `nix flake init -t github:dtomvan/templates#autounattend` `:)`
  '';
}
