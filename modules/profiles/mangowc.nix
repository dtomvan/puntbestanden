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
      };
    };

  flake.modules.nixos.profiles-mangowc = {
    imports = [
      (import "${inputs.mango}/nix/nixos-modules.nix" self)
    ];
    programs.mango.enable = true;
  };

  flake.modules.homeManager.profiles-mangowc = {
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
      '';
    };
  };
}
