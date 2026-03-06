{ self, ... }:
{
  flake.modules = {
    nixos.hosts-feather =
      { lib, ... }:
      {
        imports = with self.modules.nixos; [
          disko
          profiles-workstation
          profiles-dank

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
        ];

        programs.gaming-free = {
          enable = true;
          enableGraphical = true;
        };

        virtualisation.libvirtd.onBoot = "ignore";
        systemd.services.podman.wantedBy = lib.mkForce [ ];

        hardware.bluetooth.enable = true;

        environment.stub-ld.enable = false;
        networking.firewall.enable = false;

        services.getty.autologinUser = "tomvd";
        boot.initrd.luks.devices.crypted.device = lib.mkForce "/dev/nvme0n1p3";

        system.stateVersion = "24.11";
      };

    homeManager."tomvd@feather" =
      { pkgs, ... }:
      {
        imports = with self.modules.homeManager; [
          themes-catppuccin
          profiles-dank
          profiles-graphical
          profiles-plasma
          profiles-workstation

          firefox-ubo-only
        ];

        programs.firefox.profiles.default.extensions.packages = [
          pkgs.nur.repos.rycee.firefox-addons.onetab
        ];

        programs.plasma.configFile.kwinrc.Xwayland.Scale = 1.5;

        home.stateVersion = "24.05";
      };
  };
}
