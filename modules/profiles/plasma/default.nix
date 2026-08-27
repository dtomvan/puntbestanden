{
  self,
  lib,
  ...
}:
let
  inherit (self.modules) nixos;
  inherit (lib)
    mkDefault
    optionals
    optionalString
    ;
in
{
  flake.modules = {
    nixos.profiles-plasma =
      {
        pkgs,
        config,
        ...
      }:
      {
        imports = [ nixos.profiles-plasma-minimal ];

        config = lib.mkIf config.my.plasma.enable {
          programs.kdeconnect.enable = mkDefault true;

          environment.systemPackages =
            builtins.attrValues {
              inherit (pkgs.kdePackages)
                filelight
                krdc # remote desktop client, should get negotiated by kdeconnect
                krfb # VNC share/server
                plasma-browser-integration
                ;

              inherit (pkgs) haruna;
            }
            ++ optionals config.hardware.sane.enable [ pkgs.kdePackages.skanpage ];

          programs.firefox.nativeMessagingHosts.packages = [ pkgs.kdePackages.plasma-browser-integration ];
        };
      };

    maid.profiles-plasma =
      { config, pkgs, ... }:
      let
        cfg = config.kconfig;
      in
      {
        config = lib.mkIf config.my.plasma.enable {
          kconfig.settings = {
            kcminputrc.Mouse.cursorSize = 24;
            kwalletrc.KSecretD.Enabled = false;
          };

          file.xdg_config."autostart/plasma-theme.desktop".source =
            let
              desktopScript =
                pkgs.writeText "plasma-panels.js"
                  # js
                  ''
                    panels().forEach((panel) => panel.remove());

                    const isPlasma6 = applicationVersion.split(".")[0] == 6;

                    const panel = new Panel();
                    panel.height = 44;
                    panel.floating = false;
                    panel.alignment = "center";
                    panel.hiding = "dodgewindows";
                    panel.location = "top";
                    if (isPlasma6) {
                      panel.lengthMode = "fill";
                    }

                    panel.opacity = "opaque";

                    const panelWidgets = {};
                    panelWidgets["org.kde.plasma.kickoff"] = panel.addWidget(
                      "org.kde.plasma.kickoff",
                    );
                    var w = panelWidgets["org.kde.plasma.kickoff"];
                    w.currentConfigGroup = ["General"];
                    w.writeConfig("alphaSort", true);
                    w.writeConfig("icon", "nix-snowflake-white");

                    panelWidgets["org.kde.plasma.pager"] = panel.addWidget("org.kde.plasma.pager");

                    panelWidgets["org.kde.plasma.icontasks"] = panel.addWidget(
                      "org.kde.plasma.icontasks",
                    );
                    var w = panelWidgets["org.kde.plasma.icontasks"];
                    w.currentConfigGroup = ["General"];
                    w.writeConfig("forceStripes", false);
                    w.writeConfig("launchers", [
                      "applications:firefox-devedition.desktop",
                      "applications:org.kde.dolphin.desktop",
                      "applications:org.kde.kate.desktop",
                    ]);

                    panelWidgets["org.kde.plasma.marginsseparator"] = panel.addWidget(
                      "org.kde.plasma.marginsseparator",
                    );

                    panelWidgets["org.kde.plasma.systemtray"] = panel.addWidget(
                      "org.kde.plasma.systemtray",
                    );

                    panelWidgets["org.kde.plasma.digitalclock"] = panel.addWidget(
                      "org.kde.plasma.digitalclock",
                    );
                    var w = panelWidgets["org.kde.plasma.digitalclock"];
                    w.currentConfigGroup = ["Appearance"];
                    w.writeConfig("dateFormat", "isoDate");
                    w.writeConfig("showDate", true);
                    w.writeConfig("showWeekNumbers", true);
                  '';

              script = pkgs.writeShellScript "plasma-theme.sh" ''
                qdbus org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.evaluateScript "$(cat ${desktopScript})"
                plasma-apply-desktoptheme default
                plasma-apply-cursortheme default --size 24
                plasma-apply-colorscheme ${cfg.colorScheme}
                ${optionalString (cfg.wallpaper != null) "plasma-apply-wallpaperimage ${cfg.wallpaper}"}
                ${cfg.extraAutostart}
              '';
            in
            pkgs.writeText "plasma-theme.desktop" ''
              [Desktop Entry]
              Exec=${script}
              Name=plasma-theme
              Type=Application
              Version=1.5
            '';
        };
      };
  };
}
