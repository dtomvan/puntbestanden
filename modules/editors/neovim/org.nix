{
  flake.modules.nixvim.default = { pkgs, lib, ... }: {
    extraConfigLuaPost = ''
      require'org'.setup (${
        lib.nixvim.lua.toLua {
          org_directory = "~/org";
          org_agenda_files = [ "~/org/**/*.org" ];
          default_notes_file = "~/org/refile.org";
          notifications.enabled = true;
        }
      })
    '';
    extraPlugins =
      pkgs.vimUtils.buildVimPlugin {
        name = "org.nvim";
        src = pkgs.fetchFromGitHub {
          owner = "xheisenbugx";
          repo = "org.nvim";
          rev = "fa83ceee3f94e56d2104e74164acbd10dbf53a15";
          hash = "sha256-1OlYaVlZ0OU9/kkzos9bsuUBjuWMnIIGZDOO6vQ0ilc=";
        };
      }
      |> lib.singleton;
  };
}
