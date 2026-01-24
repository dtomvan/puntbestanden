{
  flake.modules.nixos.profiles-base.services.journald.extraConfig = ''
    SystemMaxUse=250M
    SystemMaxFileSize=50M
  '';
}
