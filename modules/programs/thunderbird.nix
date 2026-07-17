{ config, ... }:
let
  thunderbird = {
    enable = true;
    perIdentitySettings = id: {
      "mail.identity.id_${id}.protectSubject" = false;
      "mail.identity.id_${id}.autoEncryptDrafts" = false;
    };
  };
in
{
  flake.modules.homeManager.programs-thunderbird = {
    programs.thunderbird = {
      enable = true;
      profiles.default = {
        isDefault = true;
        withExternalGnupg = true;
        accountsOrder = [
          "main"
          "alt"
        ];
      };
    };

    accounts.email.accounts = {
      main = {
        name = config.users.tomvd.email;
        realName = config.users.tomvd.fullName;
        address = config.users.tomvd.email;
        flavor = "gmail.com";
        gpg.key = config.users.tomvd.gpgPubKey;
        inherit thunderbird;
        primary = true;
      };
      alt = {
        realName = config.users.tomvd.fullName;
        name = "18gatenmaker6@gmail.com";
        address = "18gatenmaker6@gmail.com";
        flavor = "gmail.com";
        inherit thunderbird;
      };
    };
  };
}
