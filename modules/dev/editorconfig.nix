{
  flake.modules.homeManager.profiles-base = {
    editorconfig = {
      enable = true;
      settings = {
        "*.nix" = {
          indent_style = "space";
          indent_size = 2;
        };
      };
    };
  };
}
