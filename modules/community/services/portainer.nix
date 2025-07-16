# What you'd normally do in docker-compose if you wanted to use portainer
{
  flake.modules.nixos.portainer = {
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
