{ config, ... }:
{
  flake.modules.homeManager.programs-thunderbird = {
    programs.thunderbird = {
      enable = true;
      profiles.default = {
        isDefault = true;
      };
    };

    accounts.email.accounts = {
      main = {
        realName = config.users.tomvd.fullName;
        address = config.users.tomvd.email;
        flavor = "gmail.com";
        gpg.key = config.users.tomvd.gpgPubKey;
        thunderbird.enable = true;
        primary = true;
      };
      alt = {
        realName = config.users.tomvd.fullName;
        address = "18gatenmaker6@gmail.com";
        flavor = "gmail.com";
        thunderbird.enable = true;
      };
    };
  };
}
