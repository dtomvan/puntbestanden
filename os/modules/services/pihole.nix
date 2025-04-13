{
  virtualisation.oci-containers.containers = {
    pihole = {
      image = "pihole/pihole:latest";
      ports = [
        "53:53/tcp"
        "53:53/udp"
        "80:80/tcp"
        "443:443/tcp"
      ];
      environment = {
          TZ = "Europe/Amsterdam";
          FTLCONF_dns_listeningMode = "all";
      };
      volumes = [
        "etc_pihole:/etc/pihole"
      ];
      extraOptions = [
        "--network=host"
        "--cap-add=NET_ADMIN"
        "--cap-add=NET_RAW"
        "--cap-add=SYS_TIME"
        "--cap-add=SYS_NICE"
      ];
    };
  };
}
