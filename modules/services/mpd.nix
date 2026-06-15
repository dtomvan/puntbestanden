{
  flake.modules.homeManager.mpd =
    { config, lib, ... }:
    let
      inherit (config.home.os) isGraphical;
    in
    {
      services.mpd = {
        enable = true;

        extraConfig =
          # pipewire only on graphical sessions
          (lib.optionalString isGraphical ''
            audio_output {
              type "pipewire"
              name "My PipeWire Output"
            }
          '')
          + (lib.optionalString (!isGraphical) ''
            audio_output {
              type "alsa"
              name "My ALSA"
              mixer_type		"hardware"
              mixer_device	"default"
              mixer_control	"PCM"
            }
          '');
      };

      services.mpd-mpris.enable = lib.mkIf isGraphical true;
      programs.ncmpcpp.enable = true;
      xdg.userDirs.enable = true;
    };
}
