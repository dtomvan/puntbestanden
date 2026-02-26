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

        programs.gaming-free = {
          enable = true;
          enableGraphical = true;
        };

        virtualisation.libvirtd.onBoot = "ignore";
        systemd.services.podman.wantedBy = lib.mkForce [ ];

        hardware.bluetooth.enable = true;

        environment.stub-ld.enable = false;
        networking.firewall.enable = false;

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

          plasma-feather
        ];

        programs.firefox.profiles.default.extensions.packages = [
          pkgs.nur.repos.rycee.firefox-addons.onetab
        ];

        programs.plasma.configFile.kwinrc.Xwayland.Scale = 1.5;

        home.stateVersion = "24.05";
      };
  };
}
