{ self, ... }:
{
  flake.modules = {
    nixos.hosts-boomer =
      { pkgs, ... }:
      {
        imports = with self.modules.nixos; [
          profiles-workstation
          profiles-catppuccin

          guest

          hardware-boomer-disko
          hardware-nvidia
          hardware-ssd

          steam

          # broken?
          # services-localsend-rs
          services-pinchflat
          services-syncthing
          services-vintagestory

          virt-kvm

          # nuschtos-search

          nix-distributed-builds
          users-remote-build
        ];

        environment.systemPackages =
          with pkgs;
          [
            (prismlauncher.override {
              jdks = [
                jdk8
                jdk17
                jdk21
                jdk24
              ];
            })

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
        imports = with self.modules.homeManager; [
          profiles-base
          profiles-graphical
          profiles-catppuccin
          profiles-plasma

          users-tomvd
          basic-cli
          firefox-ubo-only
          mpd
          typst

          plasma-boomer
        ];

        programs.firefox.profiles.default.extensions.packages = with pkgs.nur.repos.dtomvan; [
          zotero-connector
          violentmonkey
        ];
      };
  };

  flake.sopsConfig.keys.boomer = "age1p0qcwy8he6y70xk5qkp52pnaeyr2pdhhhgpjqgaxpwpu0dthhs8s099w9x";
}
