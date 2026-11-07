{
  flake.modules.maid.programs-tuios =
    {
      pkgs,
      lib,
      config,
      ...
    }:
    let
      cfg = config.programs.tuios;
      format = pkgs.formats.toml { };
    in
    {
      options.programs.tuios = {
        enable = lib.mkEnableOption "tuios";
        settings = lib.mkOption {
          inherit (format) type;
          default = { };
        };
      };

      config = {
        programs.tuios.settings = {
          startup = {
            tiled = true;
            daemon = true;
          };
          keybindings = {
            leader_key = "";
            preset = "zellij";
          };
          appearance = {
            calm = true;
            motion = "basic";
            border_style = "normal";
            frame_panels = false;
            window_title_style = "plain";
            dock_workspace_tabs = true;
            dock_pill_caps = false;
            dock_mode_pill = "tiling";
            dock_mode_split_letter = false;
            dock_compact = true;
            shared_borders = true;
            tiling_scheme = "smart_split";
            session_colors = false;
            dim_unfocused = 25;
          };

          agents.enabled = false;

          screenshot.frame = "none";

          motion = {
            confetti = "off";
            layout = "off";
            workspace = "none";
          };

          dock.right = [
            "transfers"
            "notifications"
            "copy-help"
          ];

          appearance.sidebar.enabled = false;
        };

        packages = lib.singleton pkgs.tuios;
        file.xdg_config."tuios/config.toml".source = format.generate "tuios.toml" cfg.settings;
      };
    };
}
