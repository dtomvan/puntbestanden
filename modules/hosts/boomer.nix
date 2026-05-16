{ self, ... }:
{
  hosts.amdpc1 = {
    description = "a reasonably sluggish Ryzen 5 2600 desktop PC";
    hostName = "boomer";
    system = "x86_64-linux";
    users = [ "tomvd" ];
    mainDisk = "/dev/disk/by-id/nvme-Samsung_SSD_970_EVO_1TB_S5H9NS0R412949Y";
    sshPubkey = {
      key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMm/zcLreRp8+urjzkMpU92xO4oVRoCzn2Em/kkpTjoy tomvd@boomer";
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
    networking.wirelessInterface = "wlp7s0";
    isNvidiaPascal = true;
    remoteBuild = {
      enable = true;
      settings = {
        maxJobs = 12;
        supportedFeatures = [
          "benchmark"
          "nixos-test"
          "big-parallel"
          "kvm"
        ];
        speedFactor = 4;
      };
    };
    enableHomeManager = true;
    enableNixvim = true;
    enableFlatpak = true;
  };

  flake.modules = {
    nixos.hosts-boomer =
      { pkgs, lib, ... }:
      {
        imports = builtins.attrValues {
          inherit (self.modules.nixos)
            disko
            profiles-workstation
            themes-catppuccin

            guest

            hardware-nvidia
            hardware-ssd

            gaming-free
            steam

            # broken?
            services-pinchflat
            services-syncthing

            virt-kvm
            virt-nat
            virt-incus

            nix-distributed-builds
            users-remote-build
            ;
        };

        programs.gaming-free = {
          enable = true;
          enableGraphical = true;
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
          lib.singleton (
            pkgs.prismlauncher.override {
              jdks = builtins.attrValues {
                inherit (pkgs)
                  jdk8
                  jdk17
                  jdk21
                  jdk25
                  ;
              };
            }
          )
          ++ lib.map (pkg: pkgs.lazy-app.override { inherit pkg; }) (
            builtins.attrValues {
              inherit (pkgs)
                # rarely used
                gimp
                localsend
                zotero
                ;
            }
          );

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

        system.stateVersion = "24.05";
      };

    homeManager."tomvd@boomer" =
      { pkgs, ... }:
      {
        imports = builtins.attrValues {
          inherit (self.modules.homeManager)
            profiles-workstation
            themes-catppuccin

            mpd
            typst
            ;
        };

        programs.firefox.profiles.default.extensions.packages = builtins.attrValues {
          inherit (pkgs.nur.repos.dtomvan)
            zotero-connector
            violentmonkey
            ;
        };

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
