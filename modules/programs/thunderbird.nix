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
          config.users.tomvd.email
          "18gatenmaker6@gmail.com"
        ];
      };
    };

    accounts.email.accounts = {
      ${config.users.tomvd.email} = {
        realName = config.users.tomvd.fullName;
        address = config.users.tomvd.email;
        flavor = "gmail.com";
        gpg.key = config.users.tomvd.gpgPubKey;
        inherit thunderbird;
        primary = true;
      };
      "t.oostveen@student.rug.nl" = {
        realName = "Tom Oostveen";
        address = "t.oostveen@student.rug.nl";
        flavor = "gmail.com";
        inherit thunderbird;
      };
      "18gatenmaker6@gmail.com" = {
        realName = config.users.tomvd.fullName;
        address = "18gatenmaker6@gmail.com";
        flavor = "gmail.com";
        inherit thunderbird;
      };
    };
  };
}
