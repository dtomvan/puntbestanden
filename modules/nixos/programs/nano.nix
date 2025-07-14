{
  flake.modules.nixos.programs-nano =
    let
      backupdir = "/var/lib/nano/backupdir";
    in
    {
      systemd.tmpfiles.settings = {
        "10-nano-backups" = {
          ${backupdir} = {
            d = {
              group = "root";
              mode = "0666";
              user = "root";
            };
          };
        };
      };

      # basic nano config, enabled by default
      # so many cool nano features which are just off by default...
      programs.nano.nanorc = # vim
        ''
          # backup/history
          set backup
          set backupdir ${backupdir}
          set historylog
          set multibuffer
          set positionlog
          set locking

          # indentation
          set tabsize 4
          set tabstospaces

          # wrapping
          set atblanks
          set softwrap

          # UI
          set guidestripe 80
          set constantshow
          set linenumbers
          set mouse

          # smart keys
          set afterends
          set jumpyscrolling
          set zap
          set smarthome

          # search by `grep -E`
          set regexp

          # remove trailing whitespace
          set trimblanks

          # support for nano file:1:23
          set colonparsing
        '';
    };
}
