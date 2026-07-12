{
  self,
  config,
  inputs,
  ...
}:
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
        inherit (inputs.nix-maid.nixosModules) default;

        inherit (self.modules.nixos)
          boot-systemd-boot
          nix-common
          profiles-noctalia
          profiles-graphical
          themes-catppuccin
          ;
      };

      # enabled by profiles-noctalia, prevents autologin
      programs.noctalia-greeter.enable = lib.mkForce false;

      boot.kernelPackages = inputs'.nixos-small.legacyPackages.linuxPackages_latest;
      boot.initrd.supportedFilesystems.zfs = lib.mkForce false; # TODO: not up-to-date for 7.1
      boot.supportedFilesystems.zfs = lib.mkForce false;

      services.openssh.enable = true;

      # ooh, scary backdoor! No, just for panix. Also this is my personal ISO
      # for deployage to graphical systems which I control so why would you
      # even be worried... if I want to "backdoor" my own systems then so be
      # it!!!
      users.users =
        let
          keys = [
            config.hosts.amdpc1.sshPubkey.key
            config.hosts.tpx1g8.sshPubkey.key
          ];
        in
        {
          root.openssh.authorizedKeys = { inherit keys; };
          nixos = {
            openssh.authorizedKeys = { inherit keys; };

            maid = {
              _module.args = { inherit self' inputs'; }; # TODO: factor out?
              imports = builtins.attrValues {
                inherit (self.modules.maid)
                  maid-common
                  profiles-workstation
                  profiles-noctalia
                  themes-catppuccin
                  ;
              };

              file.xdg_config.niri.source = ../../../stow/niri/dot-config/niri;

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
          };
        };

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
          };

          modules.terminals.foot.enable = true;

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

  flake.nixosConfigurations.graphical-iso = self.legacyPackages.x86_64-linux.nixosSystem {
    modules = [ self.modules.nixos.graphical-iso ];
  };

  perSystem.packages.graphical-iso =
    self.nixosConfigurations.graphical-iso.config.system.build.isoImage;
}
