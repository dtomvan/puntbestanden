{ self, lib, ... }:
{
  flake.modules = {
    nixos.profiles-workstation =
      { pkgs, ... }:
      {
        imports = builtins.attrValues {
          inherit (self.modules.nixos)
            profiles-base
            profiles-graphical

            programs-kdeconnect

            services-printing
            services-sane

            networking-wireguard
            services-keybase
            utilities
            virt-podman
            ;
        };

        documentation.dev.enable = true;

        modules.utilities.enableLazyApps = true;

        services.gnome.gnome-keyring.enable = lib.mkForce false;

        environment.systemPackages = builtins.attrValues {
          inherit (pkgs)
            # keep-sorted start
            forge-sparks
            gram
            keepassxc
            libreoffice-qt-stable
            man-pages
            mpv
            obsidian
            pdfarranger
            pika-backup
            python3
            signal-desktop
            sxiv
            thunderbird
            zathura
            # keep-sorted end
            ;
          inherit (pkgs.lixPackageSets.stable) nixpkgs-reviewFull;
          vscode = pkgs.vscode.fhsWithPackages (
            ps: with ps; [
              glibc.dev
              openssl.dev
              pkg-config
              zlib
            ]
          );
        };
      };

    homeManager.profiles-workstation = { pkgs, ... }: {
      imports = builtins.attrValues {
        inherit (self.modules.homeManager)
          profiles-graphical
          programs-keepassxc
          programs-thunderbird
          ;
      };

      xdg.mimeApps = {
        enable = true;
        defaultApplicationPackages = builtins.attrValues {
          inherit (pkgs)
            libreoffice-qt-stable
            mpv
            sxiv
            thunderbird
            zathura
            ;
        };
        defaultApplications = {
          "application/pdf" = "org.pwmt.zathura.desktop";
          "x-scheme-handler/tg" = "org.telegram.desktop.desktop";
          "x-scheme-handler/tonsite" = "org.telegram.desktop.desktop";
          "x-scheme-handler/sgnl" = "signal.desktop";
          "x-scheme-handler/signalcaptcha" = "signal.desktop";
        };
        associations.added = {
          "x-scheme-handler/mailto" = "thunderbird.desktop";
          "x-scheme-handler/webcal" = "thunderbird.desktop";
          "x-scheme-handler/webcals" = "thunderbird.desktop";
          "x-scheme-handler/net-thunderbird" = "thunderbird.desktop";
          "application/x-extension-ics" = "thunderbird.desktop";
          "text/calendar" = "thunderbird.desktop";
        };
      };
    };

    maid.profiles-workstation =
      { pkgs, ... }:
      {
        imports = builtins.attrValues {
          inherit (self.modules.maid)
            profiles-base
            ;
        };

        packages = builtins.attrValues {
          inherit (pkgs.nur.repos.dtomvan) sshp;
          inherit (pkgs) dysk;
        };
      };
  };
}
