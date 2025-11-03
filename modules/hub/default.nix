# hub - idea stolen from https://github.com/9001/asm -- bootable copyparty etc
{
  self,
  lib,
  inputs,
  withSystem,
  ...
}:
let
  modulesPath = "${inputs.nixpkgs}/nixos/modules";
in
{
  flake.modules.nixos.hub = {
    imports = [
      self.modules.nixos.services-ssh
      inputs.copyparty.nixosModules.default
      # make it more vacuum
      "${modulesPath}/profiles/image-based-appliance.nix"
    ];

    system.nixos.variant_id = "hub";

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
    # the ISO user wouldn't even know a hypothetical password
    security.sudo.wheelNeedsPassword = false;
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

      systemd-boot = {
        boot.loader = {
          systemd-boot.enable = true;
          efi.canTouchEfiVariables = true;
        };
      };
    in
    {
      hub = inputs.nixpkgs.lib.nixosSystem {
        modules = [
          self.modules.nixos.hub
          systemd-boot
          (system "x86_64-linux")
          ./_hardware-configuration.nix
        ];
      };

      hub-iso = inputs.nixpkgs.lib.nixosSystem {
        modules = [
          self.modules.nixos.hub
          "${modulesPath}/installer/cd-dvd/iso-image.nix"
          (system "x86_64-linux")
          {
            isoImage = {
              edition = "hub";
              makeEfiBootable = true;
              makeUsbBootable = true;
              # add inputs to image so that the self-installer can do it
              # without much copying
              storeContents = lib.mapAttrsToList (_n: i: i.outPath) inputs;
            };
            # always copy to RAM
            boot.initrd.systemd.services.copytoram.unitConfig.ConditionKernelCommandLine = lib.mkForce null;
          }
        ];
      };

      hub-rpi = inputs.nixpkgs.lib.nixosSystem {
        modules = [
          self.modules.nixos.hub
          "${modulesPath}/installer/sd-card/sd-image-aarch64.nix"
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

  text.readme.parts.hub = # markdown
    ''
      - A clone of 9001's [hub](https://github.com/9001/asm/blob/hovudstraum/p/hub/) ISO, except not alpine-based :sweat_smile:
    '';
}
