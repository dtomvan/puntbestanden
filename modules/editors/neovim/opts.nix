{
  flake.modules.nixvim.minimal.opts = {
    shiftwidth = 4;
    tabstop = 4;
    softtabstop = 4;
    number = true;
    relativenumber = true;
    breakindent = true;
    shortmess = "CFOSWaco";
    switchbuf = "usetab";

    expandtab = true;
    autoindent = true;
    smartindent = true;
    smartcase = true;
    infercase = true;
    spelloptions = "camel";
    formatoptions = "rqnl1j"; # improve comment editing

    wrap = true;

    scrolloff = 4;

    iskeyword = "@,48-57,_,192-255,-"; # Treat dash as `word` textobject part
    virtualedit = "block";
  };
}
