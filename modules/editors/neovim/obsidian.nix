{
  flake.modules.nixvim.default =
    { config, lib, ... }:
    {
      plugins.obsidian = {
        enable = true;

        lazyLoad.settings.cmd = "Obsidian";

        settings = {
          legacy_commands = false;

          frontmatter.enabled = false;

          completions = {
            nvim_cmp = lib.mkDefault config.plugins.cmp.enable;
            blink = lib.mkDefault config.plugins.blink-cmp.enable;
          };

          new_notes_location = "current_dir";

          workspaces = [
            {
              name = "middle-school";
              path = "~/dtomvan-vault";
            }
            {
              name = "dailies";
              path = "~/Documents/Notes/Notes";
            }
          ];
        };
      };
    };
}
