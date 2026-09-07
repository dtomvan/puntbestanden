{
  flake.modules.nixos.profiles-base.services.journald.settings.Journal = {
    SystemMaxUse = "250M";
    SystemMaxFileSize = "50M";
  };
}
