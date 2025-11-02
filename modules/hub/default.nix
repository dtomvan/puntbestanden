# hub - idea stolen from https://github.com/9001/asm -- bootable copyparty etc
{
  self,
  inputs,
  withSystem,
  ...
}:
let
  copypartyConf = "/run/copyparty/copyparty.conf";
  modulesPath = "${inputs.nixpkgs}/nixos/modules";
in
{
  flake.modules.nixos.hub =
    {
      config,
      pkgs,
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

      services.copyparty = {
        enable = true;
        package = pkgs.copyparty.override {
          withMediaProcessing = false;
          withFastThumbnails = true;
        };
        user = "me";
        group = "users";
      };

      systemd.services.setup-copyparty = {
        description = "setup a password for the copyparty config";
        wantedBy = [ "multi-user.target" ];
        before = [ "copyparty.service" ];
        path = with pkgs; [ phraze ];
        script = ''
          rand=`phraze -w4 -lq` # four short words, with a dash. entropy: 60-70 bits, its fineee

          install -Dm600 -o me -g users ${./copyparty.conf} ${copypartyConf}

          printf '\n\n[accounts]\n\tu: %s\n' "$rand" >> ${copypartyConf}
        '';
        serviceConfig = {
          Type = "oneshot";
        };
      };

      programs.bash.interactiveShellInit = lib.mkAfter ''
        if [ $(whoami) == me ]; then
          echo Copyparty credentials:
          echo
          tail -n2 ${copypartyConf}
        fi
      '';

      systemd.services.copyparty = {
        preStart = lib.mkForce ""; # don't copy a premade empty config - allow it to be mutable after boot.
        serviceConfig = {
          ExecStart = lib.mkForce "${lib.getExe config.services.copyparty.package} -c ${copypartyConf}"; # hardcode the path ourselves, not upstream
          # allow port < 2^10
          AmbientCapabilities = [ "CAP_NET_BIND_SERVICE" ];
        };
      };

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

      services.getty = {
        autologinUser = "me";
        helpLine = "Copyparty config in ${copypartyConf}";
      };
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
