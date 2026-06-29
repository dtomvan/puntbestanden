{ self, lib, ... }:
let
  withPlasma = false;
in
{
  hosts.amdpc1 = {
    description = "a reasonably sluggish Ryzen 5 2600 desktop PC";
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
    networking = {
      hostName = "boomer";
      wirelessInterface = "wlp7s0";
      wireguard = {
        enable = true;
        ips = [
          "10.0.0.1/32"
          "fd42:42:42::1/128"
        ];
      };
    };
    isNvidiaPascal = true;
    remoteBuild = {
      enable = false;
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
    enableMaid = true;
    flatpak = {
      enable = true;
      packages = [
        "com.discordapp.Discord"
        "com.obsproject.Studio"
        "org.inkscape.Inkscape"
        "io.github.dvlv.boxbuddyrs"
        "com.github.wwmm.easyeffects"
        "org.vinegarhq.Sober"
      ]
      ++ lib.optionals (!withPlasma) [
        "org.kde.skanpage"
      ];
    };
  };

  flake.modules = {
    nixos.hosts-boomer = {
      imports = builtins.attrValues {
        inherit (self.modules.nixos)
          disko
          profiles-workstation
          profiles-noctalia
          profiles-plasma
          themes-catppuccin

          guest

          hardware-nvidia
          hardware-ssd

          gaming-free
          steam

          services-syncthing

          virt-kvm
          virt-nat
          virt-incus

          nix-distributed-builds
          users-remote-build
          ;
      };

      my.plasma.enable = withPlasma;

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

      hardware.bluetooth.enable = true;

      # WARNING: this requires a user to be set, or the root password to be known.
      users.mutableUsers = false;

      environment.stub-ld.enable = false;

      system.stateVersion = "26.11";
    };

    homeManager."tomvd@boomer" =
      { pkgs, ... }:
      {
        imports = builtins.attrValues {
          inherit (self.modules.homeManager)
            profiles-workstation
            profiles-plasma
            themes-catppuccin

            mpd
            ;
        };

        my.plasma.enable = withPlasma;

        programs.firefox.profiles.dev-edition-default.extensions.packages = builtins.attrValues {
          inherit (pkgs.nur.repos.dtomvan)
            zotero-connector
            violentmonkey
            ;
        };

        home.stateVersion = "26.11";
      };

    maid."tomvd@boomer" = { pkgs, ... }: {
      imports = builtins.attrValues {
        inherit (self.modules.maid)
          profiles-workstation
          profiles-noctalia
          profiles-plasma
          themes-catppuccin
          ;
      };

      my.plasma.enable = withPlasma;

      packages =
        builtins.attrValues {
          inherit (pkgs) mpc typst;
          prismlauncher = pkgs.prismlauncher.override {
            jdks = builtins.attrValues {
              inherit (pkgs)
                jdk8
                jdk17
                jdk21
                jdk25
                ;
            };
          };
        }
        ++ map (pkg: pkgs.lazy-app.override { inherit pkg; }) (
          builtins.attrValues {
            inherit (pkgs)
              # rarely used
              gimp
              localsend
              zotero
              ;
          }
        );

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
