{ config, ... }:
{
  flake.modules.nixos.lets-encrypt.security.acme = {
    acceptTerms = true;
    defaults.email = config.users.tomvd.email;
  };
}
