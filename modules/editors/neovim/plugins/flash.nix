{
  flake.modules.nixvim.default = {
    plugins.flash = {
      enable = true;
      lazyLoad.settings.keys = [
        {
          __unkeyed-1 = "<cr>";
          __unkeyed-2 = "<cmd>lua require(\"flash\").jump()<cr>";
        }
        "f"
        "F"
        "t"
        "T"
      ];
    };
  };
}
