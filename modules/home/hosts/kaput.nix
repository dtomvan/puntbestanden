{ config, ... }:
{
  flake.modules.homeManager.hosts-kaput.imports = with config.flake.modules.homeManager; [
    profiles-base
  ];
}
