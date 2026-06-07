{ self, inputs, ... }:
let
  inherit (self.lib) system;
in
{
  flake.modules.nixos.graphical-iso =
    {
      self',
      inputs',
      pkgs,
      lib,
      modulesPath,
      ...
    }:
    {
      imports = builtins.attrValues {
        graphical-base = "${modulesPath}/installer/cd-dvd/installation-cd-graphical-base.nix";
        inherit (inputs.home-manager.nixosModules) home-manager;

        inherit (self.modules.nixos)
          boot-systemd-boot
          nix-common
          profiles-noctalia
          profiles-graphical
          themes-catppuccin
          ;
      };

      boot.kernelPackages = inputs'.nixos-small.legacyPackages.linuxPackages_latest;

      services.openssh.enable = true;

      # we use wayland the entire way through and don't want lightdm.
      services.xserver.enable = lib.mkForce false;

      environment.defaultPackages = lib.mkForce [ ]; # nothing related to us

      home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;
        backupFileExtension = "bak";
        extraSpecialArgs = { inherit self' inputs'; };

        users.nixos = {
          imports = builtins.attrValues {
            inherit (self.modules.homeManager)
              terminals
              profiles-noctalia
              themes-catppuccin
              firefox-ubo-only # yay, ublock origin in an installer ISO!
              ;
          };

          home = {
            homeDirectory = "/home/nixos";
            sessionVariables.EDITOR = "nvim";
            shell.enableShellIntegration = true;
            stateVersion = "26.11";
            username = "nixos";
            packages = builtins.attrValues {
              inherit (self'.packages) nixvim-minimal;
              inherit (pkgs)
                # keep-sorted start
                fd
                jjui
                ripgrep
                # keep-sorted end
                ;
            };
          };

          modules.terminals.foot.enable = true;

          # link muh dotfiles
          xdg.configFile.niri = {
            source = ../../../stow/niri/dot-config/niri;
            recursive = true;
          };

          programs = {
            bash = {
              enable = true;
              initExtra = ''
                if [ -z "''${WAYLAND_DISPLAY:-}" ] && ! pidof niri >/dev/null 2>&1; then
                  niri-session
                fi
              '';
            };

            firefox = {
              enable = true;
              package = pkgs.firefox-devedition;
              profiles = {
                dev-edition-default = {
                  isDefault = lib.mkForce false;
                  # new assertion that you must ack that setting extensions
                  # will remove existing ones
                  extensions.force = true;
                };
                ubo-only.isDefault = lib.mkForce true;
              };
            };

            btop.enable = true;
            git.enable = true;
            jujutsu.enable = true;
            zellij.enable = true;
          };
        };
      };

      system.stateVersion = "26.11";
    };

  flake.nixosConfigurations.graphical-iso = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      self.modules.nixos.graphical-iso
      (system "x86_64-linux")
    ];
  };

  perSystem.packages.graphical-iso =
    self.nixosConfigurations.graphical-iso.config.system.build.isoImage;
}
