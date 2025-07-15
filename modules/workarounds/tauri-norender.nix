# also plasmashell-workaround but I am not moving that here just yet
{
  flake.modules.nixos.profiles-base = {
    # fix: https://github.com/NixOS/nixpkgs/issues/413937
    environment.variables.WEBKIT_DISABLE_DMABUF_RENDERER = 1;
  };
}
