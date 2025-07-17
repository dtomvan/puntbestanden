{
  flake.modules.nixvim.default = {
    luaLoader.enable = true;
    plugins.lz-n.enable = true;

    performance = {
      byteCompileLua = {
        enable = true;
        initLua = true;
        plugins = true;
      };
    };
  };
}
