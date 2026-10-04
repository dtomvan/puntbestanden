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
        nvimSkipModules = [
          "org.agenda.view.commands"
          "org.agenda.view.actions"
          "org.agenda.view.edit"
          "org.agenda.view.calendar"
          "org.agenda.view.bulk"
          "org.agenda.view.mappings"
          "org.agenda.view.window"
          "org.agenda.view.show"
          "org.agenda.view.filters"
          "org.babel.commands"
          "org.babel.check"
          "org.babel.edit"
          "org.babel.export"
          "org.babel.inline"
          "org.babel.vars"
          "org.babel.evaluate"
          "org.babel.buffer"
          "org.babel.exec"
          "org.babel.noweb"
          "org.babel.params"
          "org.extensions.merge.driver"
          "org.extensions.cli.main"
          "org.export.ox.include"
          "org.export.ox.tables"
          "org.export.ox.pipeline"
          "org.export.ox.headlines"
          "org.export.ox.babel"
          "org.export.ox.code"
          "org.export.ox.toc"
          "org.export.ox.footnotes"
          "org.export.ox.prune"
          "org.export.ox.transcode"
          "org.export.ox.quotes"
          "org.export.ox.options"
          "org.export.ox.macros"
          "org.export.ox.links"
        ];
      }
      |> lib.singleton;
  };
}
