# It's the traditional roguelike Cataclysm: Dark Days ahead and it's an ISO file. What more could you ever want?
{
  self,
  inputs,
  ...
}:
{
  flake.modules.nixos.bootable-cdda =
    {
      pkgs,
      modulesPath,
      ...
    }:
    {
      imports = [
        "${modulesPath}/installer/cd-dvd/iso-image.nix"
        "${modulesPath}/profiles/image-based-appliance.nix"
      ];

      environment.systemPackages = with pkgs; [
        cataclysmDDA.stable.curses
        # why not make a couple other roguelikes available too
        angband
        nethack
        rogue
        # little helper that asks whether to restart cataclysm after a crash or quit
        gum
        # tools to backup saves with
        util-linux
        usbutils
      ];

      isoImage = {
        edition = "cdda";
        makeEfiBootable = true;
        makeUsbBootable = true;
      };

      environment.interactiveShellInit = ''
        cataclysm
        while true; do
          gum confirm "Cataclysm exited, restart?" || break

          cataclysm
        done

        gum confirm "OK. Shutdown?" && systemctl poweroff

        echo 'Restart CDDA with `cataclysm`'
        echo 'Your saves are in ~/.cataclysm-dda'
        echo 'Other available roguelikes: angband, nethack, rogue'
      '';

      users.users.cdda = {
        isNormalUser = true;
        hashedPassword = "";
        extraGroups = [ "wheel" ];
      };

      users.allowNoPasswordLogin = true; # shut up about the root account will you

      services.getty.autologinUser = "cdda";

      # minimal privilige escalation program, used to mount probably
      security.doas = {
        enable = true;
        wheelNeedsPassword = false;
      };
    };

  flake.nixosConfigurations.bootable-cdda = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      self.modules.nixos.bootable-cdda
      (self.lib.system "x86_64-linux")
    ];
  };

  perSystem.packages.bootable-cdda =
    self.nixosConfigurations.bootable-cdda.config.system.build.isoImage;
}
