{ self, ... }:
{
  hosts.tpx1g8 = {
    description = "the ultra-light Thinkpad X1 Carbon G8";
    hostName = "feather";
    system = "x86_64-linux";
    users = [ "tomvd" ];
    mainDisk = "/dev/disk/by-id/nvme-2-Power_SSD7015A_1TB_P1360761115";
    sshPubkey = {
      key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJ36mBHi2bPiILfqtV79sCNwj0lXP6xNZIj7bSmk8Fep tomvd@feather";
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

    wirelessInterface = "wlp0s20f3";
    remoteBuild.enable = true;

    enableHomeManager = true;
    enableNixvim = true;
    enableFlatpak = true;
  };

  flake.modules = {
    nixos.hosts-feather =
      { config, lib, ... }:
      {
        imports = builtins.attrValues {
          inherit (self.modules.nixos)
            disko
            profiles-workstation

            themes-catppuccin

            hardware-comet-lake
            hardware-elan-tp
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

        boot.kernelModules = lib.singleton "acpi_call";
        boot.extraModulePackages = lib.singleton config.boot.kernelPackages.acpi_call;

        programs.gaming-free = {
          enable = true;
          enableGraphical = true;
        };

        virtualisation.libvirtd.onBoot = "ignore";
        systemd.services.podman.wantedBy = lib.mkForce [ ];

        hardware.bluetooth.enable = true;

        environment.stub-ld.enable = false;

        system.stateVersion = "24.11";
      };

    homeManager."tomvd@feather" =
      {
        pkgs,
        lib,
        options,
        ...
      }:
      {
        imports = builtins.attrValues {
          inherit (self.modules.homeManager)
            themes-catppuccin
            profiles-workstation
            ;
        };

        programs.firefox.profiles.default.extensions.packages =
          lib.singleton pkgs.nur.repos.rycee.firefox-addons.onetab;

        programs.${if options ? programs.plasma then "plasma" else null}.configFile.kwinrc.Xwayland.Scale =
          1.5;

        home.stateVersion = "24.05";
      };
  };
}
