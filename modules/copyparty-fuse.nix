# from bartoostveen :)
{ lib, ... }:
{
  flake.modules.homeManager.copyparty-fuse = { config, ... }: {
    programs.rclone = {
      enable = lib.mkDefault true;
      remotes.toostveen-dav = {
        config = {
          type = "webdav";
          url = "https://fs.toostveen.nl";
          vendor = "owncloud";
          user = "adm";
        };

        secrets.pass = config.sops.secrets.copyparty.path;

        mounts."/" = {
          enable = true;
          mountPoint = "${config.home.homeDirectory}/copyparty";
          options = {
            poll-interval = "10s";
            umask = "002";
            vfs-cache-mode = "full";
          };
        };
      };
    };

    sops.secrets.copyparty = {
      sopsFile = ../secrets/copyparty.secret;
      format = "binary";
    };
  };
}
