{ self, ... }:
{
  hosts.tpx1g8 = {
    description = "the ultra-light Thinkpad X1 Carbon G8";
    system = "x86_64-linux";
    users = [ "tomvd" ];
    mainDisk = "/dev/disk/by-id/nvme-2-Power_SSD7015A_1TB_P1360761115";
    sshPubkey = {
      key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPEAGWn9EODHqle1nbySh5v0yQzWUIPYd5spSaMHYLdK tomvd@feather";
      # needs to be able to self-deploy
      allowedHosts = [
        "boomer"
        "feather"
        "commitit"
      ];
      allowedUsers = [
        "tomvd"
        "root"
      ];
    };

    networking = {
      hostName = "feather";

      wirelessInterface = "wlp0s20f3";

      wireguard = {
        enable = true;
        ips = [
          "10.0.0.2/32"
          "fd42:42:42::2/128"
        ];
      };
    };
    remoteBuild.enable = false;

    flatpak = {
      enable = true;
      packages = [
        "com.discordapp.Discord"
        "com.obsproject.Studio"
        "io.github.dvlv.boxbuddyrs"
      ];
    };
  };

  flake.modules = {
    nixos.hosts-feather =
      { lib, ... }:
      {
        imports = builtins.attrValues {
          inherit (self.modules.nixos)
            disko
            profiles-workstation
            profiles-plasma
            themes-catppuccin

            hardware-comet-lake
            hardware-elan-tp
            hardware-tpacpi
            # hardware-fprint

            steam
            gaming-free
            services-syncthing
            virt-kvm

            nix-distributed-builds
            users-remote-build
            virt-nixos-containers
            virt-nat
            ;
        };

        my.plasma.enable = true;

        # remove this when reinstalling
        fileSystems."/boot".device =
          lib.mkForce "/dev/disk/by-partuuid/e1a459cf-9c29-490b-b00b-bcb5cc6c2d1a";
        fileSystems."/" = {
          device = lib.mkForce "/dev/disk/by-partuuid/5ae90318-d7e2-402a-a925-3e50a8161c29";
          fsType = lib.mkForce "ext4";
        };
        swapDevices = lib.mkForce [
          { device = "/dev/disk/by-partuuid/1e2efaee-12be-466e-a9bc-7dd6c0b31f9a"; }
        ];

        services.kmscon = {
          enable = true;
          config.hwaccel = true;
        };

        programs.gaming-free = {
          enable = true;
          # enableGraphical = true;
        };

        virtualisation.libvirtd.onBoot = "ignore";
        systemd.services.podman.wantedBy = lib.mkForce [ ];

        hardware.bluetooth.enable = true;

        environment.stub-ld.enable = false;

        system.stateVersion = "26.11";
      };

    homeManager."tomvd@feather" = {
      imports = builtins.attrValues {
        inherit (self.modules.homeManager)
          themes-catppuccin
          profiles-base
          profiles-plasma
          programs-keepassxc
          profiles-graphical
          copyparty-fuse
          ;
      };
      my.plasma.enable = true;

      home.stateVersion = "26.11";
    };

    maid."tomvd@feather" = {
      imports = builtins.attrValues {
        inherit (self.modules.maid)
          profiles-workstation
          profiles-plasma
          themes-catppuccin
          ;
      };
      my.plasma.enable = true;

      kconfig.settings.kwinrc.Xwayland.Scale = 1.5;
    };
  };
}
