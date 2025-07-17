{
  flake.modules.nixvim.default.clipboard = {
    register = "unnamedplus";
    providers.wl-copy.enable = true;
  };
}
