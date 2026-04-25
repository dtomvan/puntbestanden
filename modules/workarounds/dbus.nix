# new default: dbus-broker... but it seems to be broken already...
let
  a.services.dbus.implementation = "dbus";
in
{
  flake.modules.nixos = {
    hosts-boomer = a;
    hosts-feather = a;
  };
}
