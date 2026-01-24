{ self, ... }:
{
  flake.modules = {
    nixos.hosts-boomer =
      { pkgs, ... }:
      {
        imports = with self.modules.nixos; [
          profiles-workstation
          themes-catppuccin

          guest

          hardware-boomer-disko
          hardware-nvidia
          hardware-ssd

          gaming-free
          steam

          # broken?
          # services-localsend-rs
          services-pinchflat
          services-syncthing
          services-vintagestory

          virt-kvm
          virt-incus

          # nuschtos-search

          nix-distributed-builds
          users-remote-build
        ];

        programs.gaming-free = {
          enable = true;
          enableGraphical = true;
          enableBig = true;
        };

        environment.systemPackages =
          with pkgs;
          [
            (prismlauncher.override {
              jdks = [
                jdk8
                jdk17
                jdk21
                jdk25
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
          "com.github.wwmm.easyeffects"
          "org.vinegarhq.Sober"
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
          themes-catppuccin
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

  perSystem =
    { lib, ... }:
    {
      devshells.default.env = lib.singleton {
        name = "NIX_CONFIG";
        eval = ''$([ "$(hostname)" == boomer ] && echo "builders = ")'';
      };
    };

  flake.sopsConfig.keys.boomer = "age1p0qcwy8he6y70xk5qkp52pnaeyr2pdhhhgpjqgaxpwpu0dthhs8s099w9x";
}
