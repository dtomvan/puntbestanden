{
  flake.modules.nixos.profiles-base = {
    programs.nh = {
      enable = true;
      flake = "/home/tomvd/puntbestanden/";
      clean = {
        enable = true;
        dates = "Sun *-*-* 18:00:00";
        extraArgs = "--keep 5 --keep-since 14d --nogcroots";
      };
    };
    environment.variables.NH_SHOW_ACTIVATION_LOGS = 1;
  };
}
