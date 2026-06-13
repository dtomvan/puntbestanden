{ self, ... }:
{
  flake.modules = {
    nixos.profiles-workstation =
      { pkgs, lib, ... }:
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

        services.gnome.gnome-keyring.enable = lib.mkForce false;

        environment.systemPackages = builtins.attrValues {
          inherit (pkgs)
            # keep-sorted start
            discord
            forge-sparks
            keepassxc
            libreoffice-qt6-fresh
            mpv
            obsidian
            pdfarranger
            pika-backup
            python3
            signal-desktop
            sxiv
            telegram-desktop
            thunderbird
            zathura
            # keep-sorted end
            ;
          inherit (pkgs.lixPackageSets.stable) nixpkgs-reviewFull;
        };
      };

    homeManager.profiles-workstation =
      { pkgs, ... }:
      {
        imports = builtins.attrValues {
          inherit (self.modules.homeManager)
            profiles-graphical
            profiles-noctalia
            programs-keepassxc
            ;
        };

        home.packages = builtins.attrValues {
          inherit (pkgs.nur.repos.dtomvan) sshp;
          inherit (pkgs) dysk;
        };
      };
  };
}
