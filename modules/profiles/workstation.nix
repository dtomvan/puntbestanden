{ self, ... }:
{
  flake.modules = {
    nixos.profiles-workstation =
      { pkgs, ... }:
      {
        imports = builtins.attrValues {
          inherit (self.modules.nixos)
            profiles-base
            profiles-graphical
            profiles-noctalia

            programs-kdeconnect

            services-printing
            services-sane

            networking-wireguard
            services-keybase
            utilities
            virt-podman
            ;
        };

        modules.utilities.enableLazyApps = true;

        # assumes nix-flatpak is available
        services.flatpak.packages = [
          "com.obsproject.Studio"
        ];

        environment.systemPackages = builtins.attrValues {
          inherit (pkgs)
            # keep-sorted start
            discord
            forge-sparks
            keepassxc
            libreoffice-qt6-fresh
            mpv
            nixpkgs-reviewFull
            obsidian
            pdfarranger
            pika-backup
            python3
            signal-desktop
            telegram-desktop
            thunderbird
            # keep-sorted end
            ;
        };
      };

    homeManager.profiles-workstation =
      { pkgs, ... }:
      {
        imports = builtins.attrValues {
          inherit (self.modules.homeManager)
            # profiles-base # can't import because profiles-base is already imported flake.modules.homeManager.users-tomvd
            profiles-graphical
            profiles-noctalia
            ;
        };
        home.packages = builtins.attrValues {
          inherit (pkgs.nur.repos.dtomvan) sshp;
        };
      };
  };
}
