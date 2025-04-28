{
  config,
  lib,
  pkgs,
  ...
}:
{
  options = {
  };
  config.programs.nixvim = {
    plugins.flash.enable = true;
    keymaps = [
      {
        key = "<cr>";
        action = "<cmd>lua require(\"flash\").jump()<cr>";
      }
    ];
  };
}
