{
  flake.modules.nixos.services-portainer = {
    virtualisation.oci-containers.containers = {
      portainer = {
        image = "portainer/portainer-ce:lts";
        ports = [
          "8000:8000"
          "9443:9443"
        ];
        volumes = [
          "/run/podman/podman.sock:/var/run/docker.sock"
          "portainer_data:/data"
        ];
      };
    };
  };
}
