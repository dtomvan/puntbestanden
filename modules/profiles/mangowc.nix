{ self, inputs, ... }:
{
  flake-file.inputs.mango = {
    url = "github:DreamMaoMao/mango/0.11.0";
    flake = false;
  };

  # use mangowc from nixpkgs
  perSystem =
    { pkgs, ... }:
    {
      packages = {
        mango = pkgs.mangowc;
        swayidle = pkgs.writeShellApplication {
          name = "swayidle";
          runtimeInputs = with pkgs; [
            nur.repos.dtomvan.wlr-dpms
            swayidle
            swaylock
          ];
          text = ''
            exec swayidle -w \
              timeout 300  swaylock \
              timeout 600  'wlr-dpms off' \
              resume       'wlr-dpms on' \
              before-sleep swaylock \
              lock         swaylock
          '';
        };
      };
    };

  flake.modules.nixos.profiles-mangowc = {
    imports = [
      (import "${inputs.mango}/nix/nixos-modules.nix" self)
    ];
    programs.mango.enable = true;
    security.pam.services.swaylock = {
      text = ''
        auth include login
      '';
    };
  };

  flake.modules.homeManager.profiles-mangowc =
    { self', lib, ... }:
    {
      imports = [
        (import "${inputs.mango}/nix/hm-modules.nix" self)
        self.modules.homeManager.services-fnott
      ];

      modules.terminals.foot.enable = true;

      wayland.windowManager.mango = {
        enable = true;
        systemd.xdgAutostart = true;
        autostart_sh = ''
          fnott &
          ${lib.getExe self'.packages.swayidle} &
        '';
      };
    };
}
