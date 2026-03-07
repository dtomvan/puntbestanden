{
  flake.modules.homeManager.profiles-dank =
    {
      lib,
      pkgs,
      config,
      ...
    }:
    let
      inherit (lib)
        literalMD
        mkForce
        mkIf
        mkOption
        ;
      inherit (lib.types)
        nullOr
        path
        str
        submodule
        ;

      inherit (pkgs)
        jq
        moreutils
        procps
        runCommandLocal
        ;

      inherit (pkgs.formats)
        json
        ;

      jsonFormat = json { };

      variantModule.options = {
        flavor = mkOption {
          type = str;
        };
        accent = mkOption {
          type = str;
        };
      };

      cfg = config.programs.dms-shell;
      nixThemeId = "NIX_HM_THEME";

      settingsFile = "$HOME/.config/DankMaterialShell/settings.json";
      pluginSettingsFile = "$HOME/.config/DankMaterialShell/plugin_settings.json";
      sessionFile = "$HOME/.local/state/DankMaterialShell/session.json";
    in
    {
      options.programs.dms-shell = {
        enable = lib.mkEnableOption "DMS settings";
        package = lib.mkPackageOption pkgs "dms-shell" { nullable = true; };

        settings = mkOption {
          description = "Stuff to set in ${settingsFile}";
          inherit (jsonFormat) type;
          default = { };
          example = {
            fontFamily = "JetBrainsMono Nerd Font Propo";
          };
        };

        pluginSettings = mkOption {
          description = "Stuff to set in ${pluginSettingsFile}";
          inherit (jsonFormat) type;
          default = { };
        };

        session = mkOption {
          description = "Stuff to set in ${sessionFile}";
          inherit (jsonFormat) type;
          default = { };
          example = {
            wallpaperPath = "/opt/wallpapers/my-wallpaper.png";
            perMonitorWallpaper = false;
            perModeWallpaper = false;
            wallpaperCyclingEnabled = false;
          };
        };

        theme = mkOption {
          description = "Path to theme JSON file, or null";
          type = nullOr path;
          default = null;
          example = literalMD "./catppuccin.json";
        };

        themeVariants = mkOption {
          description = "";
          type = nullOr (submodule variantModule);
          default = null;
        };
      };

      config = mkIf cfg.enable {
        programs.dms-shell.settings = mkIf (cfg.theme != null) {
          currentThemeName = mkForce "custom";
          currentThemeCategory = mkForce "registry";
          customThemeFile = mkForce (
            if cfg.themeVariants != null then
              runCommandLocal "hm-dms-theme.json" { nativeBuildInputs = [ jq ]; } ''
                jq '. | .id |= "${nixThemeId}"' ${cfg.theme} > $out
              ''
            else
              cfg.theme
          );
          registryThemeVariants = mkIf (cfg.themeVariants != null) {
            ${nixThemeId} = cfg.themeVariants;
          };
        };

        home.packages = mkIf (cfg.package != null) [ cfg.package ];

        home.activation.mergeDankMaterialShellConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
          SPONGE="${moreutils}/bin/sponge"
          JQ="${jq}/bin/jq"
          PIDOF="${procps}/bin/pidof"
          KILL="${procps}/bin/kill"

          doRestart=0
          dmsPid="$("$PIDOF" .dms-wrapped 2>/dev/null)"

          declare -rA jsonFiles=(
            [${settingsFile}]=${jsonFormat.generate "hm-dms-settings.json" cfg.settings}
            [${pluginSettingsFile}]=${jsonFormat.generate "hm-dms-plugin-settings.json" cfg.pluginSettings}
            [${sessionFile}]=${jsonFormat.generate "hm-dms-session.json" cfg.session}
          )

          for jsonFile in "''${!jsonFiles[@]}"; do
            overrideFile="''${jsonFiles[$jsonFile]}"

            oldSettings="$(cat "$jsonFile")"

            "$JQ" \
              -s \
              'reduce .[] as $item ({}; . + $item)' \
              "$jsonFile" \
              "$overrideFile" |
            "$SPONGE" "$jsonFile"

            if [ -n "$dmsPid" ] && jq -se '.[0] != .[1]' "$jsonFile" <(echo "$oldSettings"); then
              doRestart=1
            fi
          done


          if [ $doRestart -eq 1 ]; then
            "$KILL" -USR1 "$dmsPid"
          fi
        '';
      };
    };
}
