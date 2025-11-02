# hub - idea stolen from https://github.com/9001/asm -- bootable copyparty etc
{
  self,
  inputs,
  withSystem,
  ...
}:
let
  modulesPath = "${inputs.nixpkgs}/nixos/modules";
in
{
  flake.modules.nixos.hub =
    {
      lib,
      ...
    }:
    {
      imports = [
        self.modules.nixos.services-ssh
        inputs.copyparty.nixosModules.default
        # make it more vacuum
        "${modulesPath}/profiles/image-based-appliance.nix"
      ];

      system.nixos.label = "hub";

      # always copy to RAM
      boot.initrd.systemd.services.copytoram.unitConfig.ConditionKernelCommandLine = lib.mkForce null;
      users.allowNoPasswordLogin = true;

      networking = {
        hostName = "hub";
        networkmanager.enable = true;
      };

      users.groups.networkmanager.members = [ "me" ];

      # for openssh
      users.users.tomvd = {
        isNormalUser = true;
        initialHashedPassword = "";
        extraGroups = [ "wheel" ];
      };

      users.users.me = {
        isNormalUser = true;
        initialHashedPassword = "";
        extraGroups = [ "wheel" ];
      };

      services.getty.autologinUser = "me";
    };

  flake.nixosConfigurations =
    let
      system =
        s:
        (withSystem s (
          { pkgs, ... }:
          {
            nixpkgs = { inherit pkgs; };
          }
        ));
    in
    {
      hub-iso = inputs.nixpkgs.lib.nixosSystem {
        modules = [
          self.modules.nixos.hub
          "${modulesPath}/installer/cd-dvd/iso-image.nix"
          (system "x86_64-linux")
        ];
      };

      hub-rpi = inputs.nixpkgs.lib.nixosSystem {
        modules = [
          self.modules.nixos.hub
          "${modulesPath}/installer/sd-card/sd-image-raspberrypi.nix"
          (system "aarch64-linux")
        ];
      };
    };

  perSystem.packages = {
    hub-iso = self.nixosConfigurations.hub-iso.config.system.build.isoImage;
    hub-rpi = self.nixosConfigurations.hub-rpi.config.system.build.sdImage;
  };

  # allow building of rpi images on x86_64-linux
  flake.modules.nixos.profiles-workstation.boot.binfmt.emulatedSystems = [ "aarch64-linux" ];
}
