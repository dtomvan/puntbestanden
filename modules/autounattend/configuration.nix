# configuration for the TARGET system.
{
  inputs,
  self,
  config,
  ...
}:
let
  hostName = "nixos";
in
{
  flake.nixosConfigurations = rec {
    autounattend = inputs.nixpkgs.lib.nixosSystem {
      modules = [
        self.modules.nixos.autounattend
        { nixpkgs.overlays = config.pkgs-overlays; }
      ];
    };
    # allows rebuilding the config easier for a newcomer
    ${hostName} = autounattend;
  };

  flake.modules.nixos.autounattend =
    {
      pkgs,
      lib,
      ...
    }:
    {
      imports = with self.modules.nixos; [
        profiles-base
        profiles-plasma

        # allows me to remote in people's PC for quick tech support
        networking-tailscale

        inputs.home-manager.nixosModules.default

        ../hardware/_generated/autounattend.nix
        "${config.autounattend.diskoFile}" # TODO: make this the universal disko file
      ];

      programs.nh.flake = lib.mkForce "/etc/nixos/";

      nixpkgs.config.allowUnfree = true;

      nix.channel.enable = lib.mkForce true;

      networking = { inherit hostName; };

      environment.systemPackages = with pkgs; [
        gh
        git
        # does not include optional deps like ffmpeg, imagemagick, saves ~500MiB
        # closure size
        yazi-unwrapped
      ];

      services.getty = {
        helpLine = lib.strings.trim ''
          root password is "nixos"
          me password is "me"
          use nmtui to connect to Wi-Fi
        '';
      };

      home-manager.users.me = {
        imports = with self.modules.homeManager; [
          profiles-base
        ];

        home.homeDirectory = "/home/me";
        home.file.README.text = ''
          You made it!
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

          Or SSH into this device:
            $ sudo hostname non-generic-name
            $ sudo tailscale up

          Or, if you are dtomvan, grab one of your configs:
            # NH_FLAKE is already set
            $ nh os boot -H {boomer,feather,kaput}

        '';

        programs.bash = {
          enable = true;
          initExtra = # bash
            ''
              fastfetch
              systemd-analyze

              echo 'cat README for help'
            '';
        };
        home.stateVersion = "25.05";
      };

      users.users.me = {
        isNormalUser = true;
        initialPassword = "me";
      };

      users.users.root.initialPassword = "nixos";
      users.users.root.initialHashedPassword = lib.mkForce null;

      time.timeZone = "UTC";
      i18n.defaultLocale = "en_US.UTF-8";

      # We're using flakes here, don't grab the database from a non-existing
      # channel, but from the input
      programs.command-not-found.dbPath = "${inputs.nixpkgs.outPath}/programs.sqlite";

      programs.less.enable = true;
      networking.firewall.enable = true;

      system.stateVersion = "25.05";
    };
}
