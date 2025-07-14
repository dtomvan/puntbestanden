{ config, ... }:
{
  flake.modules.nixos.hosts-feather =
    { lib, ... }:
    {
      imports = with config.flake.modules.nixos; [
        profiles-workstation

        hardware-comet-lake
        hardware-elan-tp
        # hardware-fprint

        gaming-steam
        services-syncthing
        virt-kvm
      ];

      _module.args.nixinate = {
        host = "feather";
        sshUser = "tomvd";
        buildOn = "local";
        substituteOnTarget = true;
        hermetic = false;
      };

      modules = {
        printing.useHPLip = true;
      };

      virtualisation.libvirtd.onBoot = "ignore";
      systemd.services.podman.wantedBy = lib.mkForce [ ];
      virtualisation.docker.enableOnBoot = false;

      hardware.bluetooth.enable = true;

      time.timeZone = "Europe/Amsterdam";
      i18n.defaultLocale = "en_US.UTF-8";

      environment.stub-ld.enable = false;
      networking.firewall.enable = false;

      system.stateVersion = "24.11";
    };
}
