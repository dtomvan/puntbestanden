{...}: {
    programs.nixvim.keymaps = [
      {
        action = ":";
        key = ";";
      }
      {
        action = ";";
        key = ":";
      }
      {
        action = "<cmd>Telescope find_files<cr>";
        key = "<c-e>";
      }
      {
        action = "<cmd>Telescope live_grep<cr>";
        key = "<c-p>";
      }
      {
        action = "<cmd>Neotree toggle right<cr>";
        key = "<f1>";
      }
    ];
}
