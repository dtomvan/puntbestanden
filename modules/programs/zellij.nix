{ lib, ... }:
{
  flake.modules.homeManager.programs-zellij = {
    programs.zellij = {
      enable = true;

      settings = {
        pane_frames = false;
        show_startup_tips = false;
        default_shell = "bash";
        keybinds = {
          normal = {
            unbind = "Ctrl q";
          };
        };
      };

      layouts.default.layout._children = lib.singleton {
        default_tab_template._children = [
          { pane.borderless = true; }
          {
            pane = {
              size = 1;
              borderless = true;
              plugin.location = "compact-bar";
            };
          }
        ];
      };
    };
  };
}
