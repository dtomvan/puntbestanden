{ self, ... }:
{
  flake.modules = {
    nixos.hosts-feather =
      { lib, ... }:
      {
        imports = with self.modules.nixos; [
          profiles-workstation
          profiles-dank

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

        system.stateVersion = "24.11";
      };

    homeManager."tomvd@feather" =
      { pkgs, ... }:
      {
        imports = with self.modules.homeManager; [
          themes-tony
          profiles-dank
          profiles-graphical
          profiles-plasma

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
