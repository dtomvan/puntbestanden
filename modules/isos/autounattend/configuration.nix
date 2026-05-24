# configuration for the TARGET system.
{
  inputs,
  self,
  ...
}:
let
  hostName = "nixos";
  cfg = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      self.modules.nixos.autounattend
      (self.lib.system "x86_64-linux")
    ];
    specialArgs.host = null;
  };
in
{
  flake.nixosConfigurations = {
    autounattend = cfg;
    # allows rebuilding the config easier for a newcomer
    ${hostName} = cfg;
  };

  flake.modules.nixos.autounattend =
    {
      pkgs,
      lib,
      ...
    }:
    {
      imports =
        builtins.attrValues {
          inherit (self.modules.nixos)
            nix-common
            nix-sensible
            boot-systemd-boot
            profiles-plasma-minimal
            networking-tailscale
            ;
        }
        ++ [
          inputs.home-manager.nixosModules.default
          inputs.disko.nixosModules.default

          ../../community/autounattend/_disko.nix
          ../../hardware/_generated/autounattend.nix
        ];

      services.displayManager.plasma-login-manager.settings.Autologin = {
        User = "nixos";
        Session = "plasma.desktop";
      };

      programs.nh = {
        enable = true;
        flake = "/etc/nixos/";
        clean.enable = true;
      };

      nix.channel.enable = lib.mkForce true;

      networking = { inherit hostName; };

      environment.systemPackages = builtins.attrValues {
        inherit (pkgs)
          gh
          git
          # does not include optional deps like ffmpeg, imagemagick, saves ~500MiB
          # closure size
          yazi-unwrapped
          bazaar
          ;
      };

      services.getty = {
        helpLine = lib.strings.trim ''
          root password is "nixos"
          nixos password is "nixos"
          use nmtui to connect to Wi-Fi
        '';
      };

      home-manager.users.nixos = {
        home.homeDirectory = "/home/nixos";
        home.file."Desktop/README.txt".text = ''
          You made it! Your initial password for both root and user is: nixos

          Further steps:

          Either clone your own dotfiles:
            $ git clone https://github.com/me/my-dotfiles
            $ cd my-dotfiles
            $ nixos-generate-config --show-hardware-config > hardware-configuration.nix
            $ nh os boot -H myhostname .
            $ reboot

          Or setup a new config from scratch:
            $ sudo nixos-generate-config --force

          Or with flakes:
            $ sudo nixos-generate-config --flake --force

        '';

        programs.bash = {
          enable = true;
          initExtra = # bash
            ''
              fastfetch
              systemd-analyze

              echo 'cat Desktop/README.txt for help'
            '';
        };
        home.stateVersion = "26.05";
      };

      users.users.nixos = {
        isNormalUser = true;
        initialPassword = "nixos";
      };

      users.users.root.initialPassword = "nixos";
      users.users.root.initialHashedPassword = lib.mkForce null;

      time.timeZone = "UTC";
      i18n.defaultLocale = "en_US.UTF-8";

      services.openssh.enable = true;

      programs.less.enable = true;
      networking.firewall.enable = true;

      system.stateVersion = "26.05";
    };
}
