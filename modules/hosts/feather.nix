{ config, ... }:
{
  flake.modules = {
    nixos.hosts-feather =
      { lib, ... }:
      {
        imports = with config.flake.modules.nixos; [
          profiles-workstation

          hardware-comet-lake
          hardware-elan-tp
          # hardware-fprint

          steam
          services-syncthing
          virt-kvm
        ];

        virtualisation.libvirtd.onBoot = "ignore";
        systemd.services.podman.wantedBy = lib.mkForce [ ];
        virtualisation.docker.enableOnBoot = false;

        hardware.bluetooth.enable = true;

        environment.stub-ld.enable = false;
        networking.firewall.enable = false;

        system.stateVersion = "24.11";
      };

    homeManager.hosts-feather =
      { pkgs, ... }:
      {
        imports = with config.flake.modules.homeManager; [
          users-tomvd

          firefox-ubo-only

          profiles-base
          basic-cli
          profiles-graphical
          plasma
          plasma-feather
        ];

        programs.firefox.profiles.default.extensions.packages = [
          pkgs.nur.repos.rycee.firefox-addons.onetab
        ];

        programs.plasma.configFile.kwinrc.Xwayland.Scale = 1.5;
      };
  };

  flake.sopsConfig.keys.feather = "age1pjgmdxkj6zvn5hpjwd4mlv2jw89mk78luuetdcjqtmaq6r88juwshyjqal";
}
