let
  copypartyConfPath = "/run/copyparty/copyparty.conf";
  qr = "/run/copyparty/qr.txt";
in
{
  flake.modules.nixos.hub =
    {
      pkgs,
      lib,
      config,
      ...
    }:
    let
      copypartyConf = pkgs.replaceVars ./copyparty.conf {
        inherit qr;
      };
    in
    {
      services.copyparty = {
        enable = true;
        package = pkgs.copyparty.override {
          withMediaProcessing = false;
          withFastThumbnails = true;
          withTFTP = true; # required for the config
        };
        user = "me";
        group = "users";
      };

      systemd.services.setup-copyparty = {
        description = "setup a password for the copyparty config";
        wantedBy = [ "multi-user.target" ];
        before = [
          "copyparty.service"
          "getty@tty1.service" # needed to display the credentials on login
        ];
        path = with pkgs; [ phraze ];
        script = ''
          rand=`phraze -w4 -lq` # four short words, with a dash. entropy: 60-70 bits, its fineee

          mkdir -p /media
          install -Dm600 -o me -g users ${copypartyConf} ${copypartyConfPath}

          printf '\n\n[accounts]\n\tu: %s\n' "$rand" >> ${copypartyConfPath}
        '';
        serviceConfig = {
          Type = "oneshot";
        };
      };

      programs.bash.interactiveShellInit = lib.mkAfter ''
        if [ $(whoami) == me ]; then
          echo Copyparty credentials:
          echo
          tail -n2 ${copypartyConfPath}

          echo use '`systemctl restart setup-copyparty`' to regenerate the password.
          echo
          echo WARNING: your changes to the config will be overwritten
          echo
          echo QR code will appear when available

          tail -F ${qr} &
        fi
      '';

      systemd.services.copyparty = {
        preStart = lib.mkForce ""; # don't copy a premade empty config - allow it to be mutable after boot.
        serviceConfig = {
          ExecStart = lib.mkForce "${lib.getExe config.services.copyparty.package} -c ${copypartyConfPath}"; # hardcode the path ourselves, not upstream
          # allow port < 2^10
          AmbientCapabilities = [ "CAP_NET_BIND_SERVICE" ];
          RuntimeDirectoryPreserve = true; # allow getty to read the config, and only generate it once.
        };
      };

      services.getty.helpLine = "Copyparty config in ${copypartyConfPath}";
    };
}
