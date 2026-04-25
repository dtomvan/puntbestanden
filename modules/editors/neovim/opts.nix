{
  flake.modules.nixvim.default.opts = {
    shiftwidth = 4;
    tabstop = 4;
    softtabstop = 4;
    number = true;
    relativenumber = true;

    expandtab = true;
    smartindent = true;

    wrap = true;

    scrolloff = 4;
  };
}
