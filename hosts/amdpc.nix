{ pkgs, config, lib, ... }:
{
    imports = [
        ../hardware-configuration.nix
    ];
    nix.settings.experimental-features = [ "nix-command" "flakes" ];

    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;

    networking.hostname = "tom-pc";
    networking.dhcpcd.enable = true;
    networking.wireless.enable = true;
    networking.wireless.userControlled.enable = true;
    networking.wireless.networks."H369A8D363E".psk = "937F96647EE6";

    time.timeZone = "Europe/Amsterdam";
    i18n.defaultLocale = "en_US.UTF-8";

    services.pipewire = {
        enable = true;
        pulse.enable = true;
    };

    users.mutableUsers = false;
    users.users.tomvd = {
        isNormalUser = true;
        createHome = true;
        # not sure which are needed but I don't want to debug these again
        extraGroups = [ "wheel" "kvm" "audio" "seat" "libvirt" "lp" "audio" ];
        packages = with pkgs; [
            hyprland
            neovim
            btop
            du-dust
            eza
            fd
            jq
            ripgrep
            zathura
        ];
        hashedPassword = "$6$H7z49YyQ3UJkW5rC$C.EWZnpCX9c1/OJPB.sbq9iqFbEwrHYsm2Whn5GbJJPsu05VFWo3V71sxUydb9rhLjDUB.pqVwiESolfOORID0";
    };
    programs.neovim.defaultEditor = true;
    xdg.portal.wlr.enable = true;
    xdg.portal.extraPortals = with pkgs; [ xdg-desktop-portal-hyprland ];
    services.greetd.enable = true;

    environment.systemPackages = with pkgs; [
        home-manager
        wget
        curl
        nixos-rebuild
    ];

    programs.gnupg.agent = {
        enable = true;
        enableSSHSupport = true;
    };

    programs.less.enable = true;
    programs.command-not-found.enable = false;

    environment.stub-ld.enable = false;
    networking.firewall.enable = false;

    system.stateVersion = "24.05";
}
