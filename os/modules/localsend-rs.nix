{
  inputs,
  config,
  ...
}:
{
  imports = [
    inputs.localsend-rs.nixosModules.localsend-rs
  ];

  services.localsend-rs = {
    enable = true;
    user = "tomvd";
  };

  # to access the repo
  nix = {
    extraOptions = ''
      !include ${config.sops.secrets.localsend-rs.path}
    '';
  };

  sops.secrets.localsend-rs = {
    mode = "0440";
    sopsFile = ../../secrets/localsend-rs.secret;
    format = "binary";
    owner = "tomvd";
    group = "users";
  };
}
