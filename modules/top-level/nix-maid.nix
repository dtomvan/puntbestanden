{
  self,
  inputs,
  lib,
  config,
  withSystem,
  ...
}:
let
  inherit (builtins)
    attrNames
    concatMap
    listToAttrs
    filter
    ;
  inherit (lib)
    nameValuePair
    mkOption
    ;
  inherit (lib.types) lines nullOr str;

  hosts = config.hosts |> builtins.attrValues |> builtins.filter (host: host.hasConfig);

  makeNixMaid =
    system: user:
    hosts
    |> filter (host: host.system == system)
    |> map (
      host:
      nameValuePair "maid-${user}@${host.networking.hostName}" (
        withSystem host.system (
          {
            self',
            inputs',
            pkgs,
            ...
          }:
          inputs.nix-maid pkgs {
            imports = [
              (self.modules.maid."${user}@${host.networking.hostName}" or { })
              (self.modules.maid.${user} or { })
              self.modules.maid.maid-common
            ];
            _module.args = { inherit self' inputs'; };
          }
        )
      )
    );
in
{
  flake-inputs.nix-maid.url = "git+https://codeberg.org/viperML/nix-maid";
  flake-inputs.kconfig-declarative = {
    url = "git+https://codeberg.org/viperML/kconfig-declarative";
    flake = false;
  };

  perSystem = { system, ... }: {
    packages =
      config.users
      |> attrNames
      |> concatMap (makeNixMaid system)
      |> listToAttrs;
  };

  # these options only have effect when profiles-plasma is
  # imported, but for simplicity just unconditionally making them
  # available.
  flake.modules.maid.maid-common = { pkgs, ... }: {
    options.kconfig = {
      colorScheme = mkOption {
        type = str;
        default = "BreezeDark";
      };
      wallpaper = mkOption {
        type = nullOr str;
        default = null;
      };
      extraAutostart = mkOption {
        type = lines;
        default = "";
      };
    };

    config.kconfig.package = pkgs.callPackage inputs.kconfig-declarative { };
  };
}
