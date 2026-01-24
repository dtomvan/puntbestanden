{ self, ... }:
{
  flake.modules = {
    nixos.hosts-kaput =
      {
        pkgs,
        ...
      }:
      {
        imports = with self.modules.nixos; [
          profiles-base

          utilities
          networking-tailscale

          pihole
          portainer
          services-syncthing
        ];

        time.timeZone = "Europe/Amsterdam";
        i18n.defaultLocale = "en_US.UTF-8";

        users.users.een = {
          isNormalUser = true;
          description = "123";
          extraGroups = [
            "networkmanager"
            "wheel"
          ];
        };

        environment.systemPackages = with pkgs; [
          tmux
        ];

        programs.nix-ld.enable = true;
        services.envfs.enable = true;

        networking.firewall.enable = false;

        system.stateVersion = "25.05";
      };

    homeManager.hosts-kaput.imports = with self.modules.homeManager; [
      profiles-base
      users-tomvd
    ];
  };
}
