let
  font-family = "Afio";
  title-font = "${font-family}:size=14";
  summary-font = "${font-family}:size=12";
  body-font = "${font-family}:size=12";
in
{
  flake.modules.homeManager.services-fnott.services.fnott = {
    enable = true;
    settings = {
      main = {
        edge-margin-vertical = 30;
        edge-margin-horizontal = 30;
      };

      low = {
        inherit
          title-font
          summary-font
          body-font
          ;
      };

      normal = {
        inherit
          title-font
          summary-font
          body-font
          ;
      };

      critical = {
        inherit
          title-font
          summary-font
          body-font
          ;
      };
    };
  };
}
