{ self, ... }:
{
  flake.modules = {
    nixos.hosts-boomer =
      { pkgs, lib, ... }:
      {
        imports = with self.modules.nixos; [
          profiles-workstation
          themes-catppuccin

          guest

          hardware-nvidia
          hardware-ssd

          gaming-free
          steam

          # broken?
          # services-localsend-rs
          services-pinchflat
          services-syncthing
          services-vintagestory

          virt-kvm
          virt-incus

          nix-distributed-builds
          users-remote-build
        ];

        programs.gaming-free = {
          enable = true;
          enableGraphical = true;
          enableBig = true;
        };

        # <boomer patches from the shared disko config>
        disko.devices.disk.main.content.partitions = {
          BOOT.size = "2G";
          swap.size = "20G";
        };

        # remove this when reinstalling
        fileSystems."/boot".device =
          lib.mkForce "/dev/disk/by-partuuid/0e39e9d4-5be8-4676-901e-dd9723abea28";
        fileSystems."/" = {
          device = lib.mkForce "/dev/disk/by-partuuid/ad7785bf-cbe1-41e0-9ec5-359e0c79794e";
          fsType = lib.mkForce "ext4";
        };
        swapDevices = lib.mkForce [
          { device = "/dev/disk/by-uuid/34bbdbae-aea7-4b7f-bf9c-046bd44c7349"; }
        ];
        # <boomer patches from the shared disko config />

        environment.systemPackages =
          with pkgs;
          [
            (prismlauncher.override {
              jdks = [
                jdk8
                jdk17
                jdk21
                jdk25
              ];
            })
          ]
          ++ lib.map (pkg: lazy-app.override { inherit pkg; }) [
            # rarely used
            gimp
            localsend
            zotero
          ];

        services.flatpak.packages = [
          "org.inkscape.Inkscape"
          "io.github.dvlv.boxbuddyrs"
          "com.github.wwmm.easyeffects"
          "org.vinegarhq.Sober"
        ];

        hardware.bluetooth.enable = true;

        # WARNING: this requires a user to be set, or the root password to be known.
        users.mutableUsers = false;

        environment.stub-ld.enable = false;
        networking.firewall.enable = false;

        system.stateVersion = "24.05";
      };

    homeManager."tomvd@boomer" =
      { pkgs, ... }:
      {
        imports = with self.modules.homeManager; [
          profiles-graphical
          themes-catppuccin
          profiles-plasma

          firefox-ubo-only
          mpd
          typst

          plasma-boomer
        ];

        programs.firefox.profiles.default.extensions.packages = with pkgs.nur.repos.dtomvan; [
          zotero-connector
          violentmonkey
        ];

        home.stateVersion = "24.05";
      };
  };

  perSystem =
    { lib, ... }:
    {
      devshells.default.env = lib.singleton {
        name = "NIX_CONFIG";
        eval = ''$([ "$(hostname)" == boomer ] && echo "builders = ")'';
      };
    };
}
