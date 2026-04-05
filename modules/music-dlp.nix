{
  perSystem =
    { pkgs, lib, ... }:
    {
      packages.music-dlp = pkgs.callPackage (
        {
          writeShellApplication,
          yt-dlp,
          opts ? { },
        }:
        let
          defaultOpts = {
            embed-metadata = true;
            embed-thumbnail = true;
            extract-audio = true;
            mtime = true;
            newline = true;
            restrict-filenames = true;
            write-description = true;

            format = "ba/b";

            paths = "~/Music";
            output = "%(uploader)s/%(album)s/%(playlist_index,playlist_autonumber&{}. |)s%(title)s.%(ext)s";

            concurrent-fragments = 3;
            sponsorblock-remove = "music_offtopic,sponsor,intro,outro";
            postprocessor-args = ''ThumbnailsConvertor:-qmin 1 -q:v 1 -vf crop="'if(gt(ih,iw),iw,ih)':'if(gt(iw,ih),ih,iw)'"'';
            convert-thumbnails = "jpg";
          };

          finalOpts = defaultOpts // opts;
        in

        writeShellApplication {
          name = "music-dlp";
          runtimeInputs = [ yt-dlp ];
          runtimeEnv.YT_DLP_OPTS = lib.cli.toCommandLineGNU { } finalOpts;
          text = ''
            yt-dlp "''${YT_DLP_OPTS[@]:?}" "$@"
          '';
        }
      ) { };
    };
}
