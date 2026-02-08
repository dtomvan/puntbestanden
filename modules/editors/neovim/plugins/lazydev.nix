{ lib, ... }:
{
  flake.modules.nixvim.default = {
    plugins.lazydev.enable = true;
    plugins.cmp.settings.sources = lib.singleton {
      name = "lazydev";
      group_index = 0;
    };
  };
}
