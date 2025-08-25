{
  flake.modules.nixvim.default = {
      plugins.lean.enable = true;
      dependencies.lean.enable = true;
  };
}
