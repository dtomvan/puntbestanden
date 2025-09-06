{ config, ... }:
{
  flake.modules = {
    nixos.hosts-boomer =
      { pkgs, ... }:
      {
        imports = with config.flake.modules.nixos; [
          profiles-workstation

          guest

          hardware-boomer-disko
          hardware-nvidia
          hardware-ssd

          steam

          services-localsend-rs
          services-syncthing
          services-vintagestory

          virt-kvm

          nuschtos-search

          nix-distributed-builds
          users-remote-build
        ];

        environment.systemPackages =
          with pkgs;
          [
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

        services.flatpak.packages = [
          "org.inkscape.Inkscape"
          "io.github.dvlv.boxbuddyrs"
        ];

        hardware.bluetooth.enable = true;

        # WARNING: this requires a user to be set, or the root password to be known.
        users.mutableUsers = false;

        environment.stub-ld.enable = false;
        networking.firewall.enable = false;

        system.stateVersion = "24.05";
      };

    homeManager.hosts-boomer =
      { pkgs, ... }:
      {
        imports = with config.flake.modules.homeManager; [
          users-tomvd
          profiles-base
          basic-cli
          profiles-graphical

          firefox-ubo-only

          typst
          latex
          mpd
          plasma
          plasma-boomer
        ];

        modules.latex = {
          enable = true;
          kile = true;
        };

        programs.firefox.profiles.default.extensions.packages = with pkgs.nur.repos.dtomvan; [
          zotero-connector
          violentmonkey
        ];
      };
  };

  flake.sopsConfig.keys.boomer = "age1p0qcwy8he6y70xk5qkp52pnaeyr2pdhhhgpjqgaxpwpu0dthhs8s099w9x";
}
