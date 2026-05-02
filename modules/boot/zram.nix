{
  flake.modules.nixos.profiles-base = {
    zramSwap.enable = true;
    systemd.oomd = {
      enable = true;
      # copy fedora's default:
      # https://github.com/NixOS/nixpkgs/blob/755f5aa91337890c432639c60b6064bb7fe67769/nixos/modules/system/boot/systemd/oomd.nix#L26-L27
      enableRootSlice = true;
      enableUserSlices = true;
    };
  };
}
