{
  flake.modules.nixvim.default =
    { pkgs, ... }:
    {
      plugins.telescope = {
        enable = true;
        luaConfig.post = ''
          require'telescope'.load_extension 'tasks'
        '';
      };
      extraConfigLuaPost = ''
        require'tasks'.setup { add_commands = true }
      '';
      extraPlugins = [
        (pkgs.vimUtils.buildVimPlugin {
          name = "tasks";
          src = pkgs.fetchFromGitHub {
            owner = "dtomvan";
            repo = "tasks.nvim";
            rev = "2bee85143d4b585080b9cdff83dd166ff672e377";
            hash = "sha256-a72dV/FqeunTwtDMB2ScvPS+40qlnq4tyn+jguteGrc=";
          };
        })
      ];
    };
}
