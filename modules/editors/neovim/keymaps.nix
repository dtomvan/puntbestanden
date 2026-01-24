{
  flake.modules.nixvim.default.keymaps = [
    {
      action = ":";
      key = ";";
    }
    {
      action = ";";
      key = ":";
    }
    {
      action = "mlggyG`l";
      key = "<space>y";
    }
    {
      action = "<cr>";
      key = ",<cr>";
    }
    {
      action = "<cmd>cn<cr>";
      key = "<space>j";
    }
    {
      action = "<cmd>cp<cr>";
      key = "<space>k";
    }
  ];
}
