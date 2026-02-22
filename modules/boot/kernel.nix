{
  flake.modules.nixos.boot-linux-latest =
    { pkgs, ... }:
    {
      boot.kernelPackages = pkgs.linuxPackages_latest;
    };
}
