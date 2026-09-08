{
  flake.modules.homeManager.cs-calendars.accounts.calendar.accounts = {
    cs-group-5 = {
      thunderbird = {
        enable = true;
        color = "#ff6600";
      };
      remote = {
        type = "caldav";
        url = "https://rooster.rug.nl/maat/api/2026-2027/schedule/2bab6ad5-7446-4aaf-9174-c06a70a9c973";
      };
    };

    cs-y1 = {
      thunderbird = {
        enable = true;
        color = "#33ff33";
      };
      remote = {
        type = "caldav";
        url = "https://rooster.rug.nl/maat/api/2026-2027/schedule/2fec0d5f-4cd4-4d8d-a1d0-ac140e4319d8";
      };
    };
  };
}
