{ config, ... }:
{
  flake.modules.nixos.hosts-feather =
    { pkgs, lib, ... }:
    {
      imports = with config.flake.modules.nixos; [
        profiles-base
        profiles-kde

        hardware-comet-lake
        hardware-elan-tp
        # hardware-fprint

        utilities

        gaming-steam

        networking-tailscale

        services-keybase
        services-syncthing

        virt-kvm
        virt-distrobox
        virt-docker
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
        utilities.enableLazyApps = true;
      };

      environment.systemPackages =
        with pkgs;
        [
          keepassxc
        ]
        ++ lib.map (pkg: lazy-app.override { inherit pkg; }) [
          # rarely used
          libreoffice-qt6-fresh
        ];

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
