{
  flake.modules.nixvim.default = {
    plugins.flash.enable = true;
    keymaps = [
      {
        key = "<cr>";
        action = "<cmd>lua require(\"flash\").jump()<cr>";
      }
    ];
  };
}
