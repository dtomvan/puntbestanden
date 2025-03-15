{pkgs, lib, ...}: {
  virtualisation.podman.dockerCompat = lib.mkForce false;
  virtualisation.docker.enable = true;
  environment.systemPackages = with pkgs; [
    docker-buildx
  ];
}

