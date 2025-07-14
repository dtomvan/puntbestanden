{ config, ... }:
{
  flake.modules.nixos.hosts-boomer =
    { pkgs, ... }:
    {
      imports = with config.flake.modules.nixos; [
        profiles-base
        profiles-kde

        hardware-boomer-disko
        hardware-nvidia
        hardware-ssd

        utilities

        networking-tailscale

        gaming-steam

        services-keybase
        services-localsend-rs
        services-syncthing
        services-vintagestory

        virt-distrobox
        virt-docker
        virt-kvm
      ];

      _module.args.nixinate = {
        host = "boomer";
        sshUser = "tomvd";
        buildOn = "remote";
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
          libreoffice-qt6-fresh

          keepassxc
          # fuck flatpaks they don't even work half the time
          discord
          thunderbird
          obsidian

          (prismlauncher.override {
            jdks = [
              jdk8
              jdk17
              jdk21
              jdk24
            ];
          })

          python3

          nur.repos.dtomvan.tsodingPackages.blang
          nur.repos.dtomvan.tsodingPackages.musializer
          nur.repos.dtomvan.tsodingPackages.fourat
          nur.repos.dtomvan.tsodingPackages.sowon
        ]
        ++ lib.map (pkg: lazy-app.override { inherit pkg; }) [
          # rarely used
          zotero
          localsend
          gimp
        ];

      hardware.bluetooth.enable = true;

      time.timeZone = "Europe/Amsterdam";
      i18n.defaultLocale = "en_US.UTF-8";

      # WARNING: this requires a user to be set, or the root password to be known.
      users.mutableUsers = false;

      environment.stub-ld.enable = false;
      networking.firewall.enable = false;

      system.stateVersion = "24.05";
    };
}
