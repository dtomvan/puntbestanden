{
  flake.modules.nixvim.default = {
    opts = {
      sw = 4;
      ts = 4;
      sts = 4;
      nu = true;
      rnu = true;

      et = true;
      si = true;

      wrap = true;

      scrolloff = 4;
    };
  };
}
