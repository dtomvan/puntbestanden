{
  flake.modules.nixos.profiles-base =
    { inputs', ... }:
    {
      boot.kernelPackages = inputs'.nixos-small.legacyPackages.linuxPackages;
    };
}
