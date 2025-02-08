{
  pkgs,
  config,
  lib,
  ...
}: {
  environment.systemPackages = with pkgs; [
    docker-compose
    docker-buildx
  ];

  virtualisation.docker.enable = true;
}
