{ config, inputs, ... }:
{
  flake.modules.nixos.profiles-base =
    { pkgs, ... }:
    {
      imports = with config.flake.modules.nixos; [
        inputs.disko.nixosModules.disko
        inputs.sops.nixosModules.sops
        inputs.srvos.nixosModules.mixins-terminfo

        nix-common
        nix-distributed-builds

        boot-systemd-boot
        users-tomvd
        users-root

        services-ssh

        programs-comma
        programs-gpg
        programs-less
        programs-nano

        networking-wifi-passwords

        undollar
      ];

      environment.systemPackages = with pkgs; [
        bat
        btop
        du-dust
        eza
        fastfetch
        fd
        file
        glow
        gron
        jq
        just
        neovim
        nixfmt-rfc-style
        rink
        ripgrep
        skim
        tealdeer
      ];
    };
}
