{
  flake.modules.nixos.hardware-tpacpi =
    { lib, ... }:
    {
      boot.kernelModules = lib.singleton "thinkpad_acpi";
    };
}
