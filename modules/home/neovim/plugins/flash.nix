{
  flake.modules.homeManager.neovim = {
    programs.nixvim = {
      plugins.flash.enable = true;
      keymaps = [
        {
          key = "<cr>";
          action = "<cmd>lua require(\"flash\").jump()<cr>";
        }
      ];
    };
  };
}
