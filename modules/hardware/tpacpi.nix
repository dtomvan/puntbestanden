{
  flake.modules.nixos.hardware-tpacpi =
    {
      pkgs,
      lib,
      config,
      ...
    }:
    {
      boot.kernelModules = lib.singleton "acpi_call";
      boot.extraModulePackages = lib.singleton config.boot.kernelPackages.acpi_call;
      environment.systemPackages = lib.singleton pkgs.tpacpi-bat;
    };
}
