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

    cs-logic = {
      remote = {
        type = "http";
        url = "https://cal.toostveen.nl/rug/calendar.ics?courseOffering=WBCS030-05.2026-2027.1";
      };
      thunderbird = {
        enable = true;
        color = "#33ff33";
      };
    };
    cs-pf = {
      remote = {
        type = "http";
        url = "https://cal.toostveen.nl/rug/calendar.ics?courseOffering=WBCS046-10.2026-2027.1";
      };
      thunderbird = {
        enable = true;
        color = "#33ff33";
      };
    };
    cs-ics = {
      remote = {
        type = "http";
        url = "https://cal.toostveen.nl/rug/calendar.ics?courseOffering=WBCS005-05.2026-2027.1";
      };
      thunderbird = {
        enable = true;
        color = "#33ff33";
      };
    };
    cs-dst = {
      remote = {
        type = "http";
        url = "https://cal.toostveen.nl/rug/calendar.ics?courseOffering=WBCS011-05.2026-2027.1";
      };

      thunderbird = {
        enable = true;
        color = "#33ff33";
      };
    };
    cs-arch = {
      remote = {
        type = "http";
        url = "https://cal.toostveen.nl/rug/calendar.ics?courseOffering=WBCS010-05.2026-2027.1";
      };

      thunderbird = {
        enable = true;
        color = "#33ff33";
      };
    };
  };
}
