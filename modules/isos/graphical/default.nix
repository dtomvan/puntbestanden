{ self, inputs, ... }:
let
  inherit (self.lib) system;
  inherit (self.modules.nixos)
    boot-systemd-boot
    nix-common
    profiles-noctalia
    profiles-graphical
    services-ssh
    themes-catppuccin
    ;
  inherit (self.modules) homeManager;
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
      imports = [
        "${modulesPath}/installer/cd-dvd/installation-cd-graphical-base.nix"
        inputs.home-manager.nixosModules.home-manager

        boot-systemd-boot
        nix-common
        profiles-noctalia
        profiles-graphical
        services-ssh
        themes-catppuccin
      ];

      # we use wayland the entire way through and don't want lightdm.
      services.xserver.enable = lib.mkForce false;

      services.displayManager.dms-greeter.enable = lib.mkForce false;

      environment.defaultPackages = lib.mkForce [ ]; # nothing related to us

      home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;
        backupFileExtension = "bak";
        extraSpecialArgs = { inherit self' inputs'; };

        users.nixos = {
          imports = [
            homeManager.terminals
            homeManager.profiles-noctalia
            homeManager.themes-catppuccin
            homeManager.firefox-ubo-only # yay, ublock origin in an installer ISO!
          ];

          home = {
            homeDirectory = "/home/nixos";
            sessionVariables.EDITOR = "nvim";
            shell.enableShellIntegration = true;
            stateVersion = "26.05";
            username = "nixos";
            packages =
              lib.singleton self'.packages.nixvim-minimal
              ++ builtins.attrValues {
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
              shellAliases.sudo = "run0";
            };

            firefox = {
              enable = true;
              package = self'.legacyPackages.makeFakeFirefox pkgs.firefox-devedition {
                args = "-P ubo-only";
              };
              profiles = {
                default = {
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

      system.stateVersion = "26.05";
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
