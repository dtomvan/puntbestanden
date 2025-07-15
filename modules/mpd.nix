{
  flake.modules.homeManager.mpd =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    {
      services.mpd = {
        enable = true;

        # TODO: this is the only part where I have a remnant of the old way
        # `hosts` was used, maybe remove this?
        extraConfig =
          # pipewire only on graphical sessions
          (lib.optionalString config.home.os.isGraphical ''
            audio_output {
              type "pipewire"
              name "My PipeWire Output"
            }
          '')
          + (lib.optionalString (!config.home.os.isGraphical) ''
            audio_output {
              type "alsa"
              name "My ALSA"
              mixer_type		"hardware"
              mixer_device	"default"
              mixer_control	"PCM"
            }
          '');
      };

      home.packages = with pkgs; [
        mpd
        mpc
      ];

      services.mpd-mpris.enable = true;
      programs.ncmpcpp.enable = true;
      xdg.userDirs.enable = true;
    };
}
