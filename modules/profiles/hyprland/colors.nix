{
  flake.modules.homeManager.hyprland =
    { lib, ... }:
    with lib;
    let
      isHex = str: match "[0-9a-fA-F]+" str != null;
      isRGB = color: isHex color && stringLength color == 6;
      isRGBA = color: isHex color && stringLength color == 8;

      toRGB = color: substring 0 6 color;
      toRGBA = color: "${substring 0 6 color}FF";

      minusHex = a: b: toHexString ((fromHexString a) - (fromHexString b));
      complementRGB = color: minusHex "FFFFFF" color;
      complementRGBA = color: minusHex "FFFFFFFF" color;
      complement = color: {
        RGB = complementRGB color.RGB;
        RGBA = complementRGBA color.RGBA;
      };

      makeColor =
        color:
        if isRGB color then
          {
            RGB = color;
            RGBA = toRGBA color;
          }
        else if isRGBA color then
          {
            RGB = toRGB color;
            RGBA = color;
          }
        else
          throw "Not a color";

      accentColor = makeColor "33ccffee";
      compAccentColor = complement accentColor;

      backgroundColor = makeColor "000000AA";

      grey = makeColor "595959aa";
    in
    {
      wayland.windowManager.hyprland = {
        settings = {
          general = {
            "col.active_border" = "rgba(${accentColor.RGBA})";
            "col.inactive_border" = "rgba(${grey.RGBA})";
          };
        };
      };

      programs.tofi.settings = {
        background-color = "#${backgroundColor.RGBA}";
        selection-color = "#${accentColor.RGB}";
        selection-match-color = "#${compAccentColor.RGB}";
      };

      services.fnott.settings =
        let
          background = backgroundColor.RGBA;
        in
        {
          low = { inherit background; };
          normal = { inherit background; };
          critical.background = "6c3333AA";
        };
    };
}
