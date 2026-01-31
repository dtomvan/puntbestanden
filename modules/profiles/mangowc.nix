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
        hypridle = pkgs.writeShellApplication {
          name = "hypridle";
          runtimeInputs = with pkgs; [
            nur.repos.dtomvan.wlr-dpms
            hypridle
            swaylock
          ];
          # HACK: the promised `-c` flag for hypridle doesn't actually work.
          # Making a fake XDG_CONFIG_HOME.
          text = ''
            XDG_CONFIG_HOME=${pkgs.writeTextDir "hypr/hypridle.conf" ''
              general {
                  before_sleep_cmd = pidof swaylock || swaylock
                  lock_cmd = pidof swaylock || swaylock
                  unlock_cmd = pkill -USR1 swaylock
              }

              listener {
                  timeout = 300
                  on-timeout = swaylock
              }

              listener {
                  timeout = 360
                  on-timeout = wlr-dpms off
                  on-resume = wlr-dpms on
              }
            ''} exec hypridle
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
          ${lib.getExe self'.packages.hypridle} &
        '';
      };
    };
}
