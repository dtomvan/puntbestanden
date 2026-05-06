{
  flake.modules.nixvim.minimal.clipboard = {
    register = "unnamedplus";
    providers.wl-copy.enable = true;
  };
}
