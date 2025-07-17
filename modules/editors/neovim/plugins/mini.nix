{
  flake.modules.nixvim.default = {
    plugins.mini = {
      enable = true;
      modules = {
        ai = { };
        basics = {
          options = {
            basic = true;
            extra_ui = true;
          };
          mappings.windows = true;
          autocommands = {
            basic = true;
          };
        };
        bracketed = { };
        comment = { };
        icons = { };
        indentscope = { };
        notify = { };
        sessions = { };
        statusline = { };
        # pairs = {};
        surround = {
          mappings = {
            app = "ys";
            delete = "ds";
            find = "";
            find_left = "";
            highlight = "";
            replace = "cs";
            update_n_lines = "";
            suffix_last = "";
            suffix_next = "";
          };
          search_method = "cover_or_next";
        };
      };
      mockDevIcons = true;
    };
  };
}
