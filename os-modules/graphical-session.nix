{pkgs, ...}: {
  programs.hyprland = {
    enable = true;
    package = pkgs.hyprland;
    portalPackage = pkgs.xdg-desktop-portal-hyprland;
  };
  xdg.portal.wlr.enable = true;
  xdg.portal.extraPortals = with pkgs; [
    xdg-desktop-portal-hyprland
    xdg-desktop-portal-gtk
  ];
  services.greetd.enable = true;
  services.greetd.settings.default_session = {
    command = "${pkgs.greetd.greetd}/bin/agreety --cmd Hyprland";
  };
}
