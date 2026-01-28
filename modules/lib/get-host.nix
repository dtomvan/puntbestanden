toplevel@{ lib, ... }:
{
  flake.lib.getHost =
    {
      config,
      module ? config.networking.hostName,
      doThrow ? true,
    }:
    lib.findSingle (h: h.hostName == config.networking.hostName)
      (if doThrow then throw "no host configured for ${module}" else null)
      (if doThrow then throw "multiple hosts with same hostname" else null)
      (lib.attrValues toplevel.config.hosts);
}
