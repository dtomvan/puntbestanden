{
  flake.modules.nixos.profiles-base = {
    programs.nh = {
      enable = true;
      flake = "/home/tomvd/puntbestanden/";
      clean = {
        enable = true;
        dates = "weekly";
        extraArgs = "--keep 5 --keep-since 14d --nogcroots";
      };
    };
  };
}
