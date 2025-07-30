{ inputs, lib, ... }:
let
  user = "tomvd";
  group = "users";
in
{
  flake-file.inputs.copyparty = {
    # TODO: bump manually on new release, you could make a flake app that does
    # this but yeah it doesn't really matter
    url = "github:9001/copyparty/5df2cbe5d76db8aee7d37a92b5a2670ef1084044";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  pkgs-overlays = [ inputs.copyparty.overlays.default ];

  flake.modules.nixos.profiles-base =
    { config, pkgs, ... }:
    let
      package = pkgs.copyparty.override {
        withFastThumbnails = true;
        withMediaProcessing = false; # uses ffmpeg, which can eat your CPU big time
        # uses mutagen, should be quicker as well, also saves closure size!
        withBasicAudioMetadata = true;
      };
    in
    {
      imports = [ inputs.copyparty.nixosModules.default ];

      sops.secrets.copyparty = {
        mode = "0400";
        sopsFile = ../../secrets/copyparty.secret;
        format = "binary";
        owner = user;
        inherit group;
      };

      sops.secrets.copyparty-weak = {
        mode = "0400";
        sopsFile = ../../secrets/copyparty-weak.secret;
        format = "binary";
        owner = user;
        inherit group;
      };

      environment.systemPackages = [
        package
        pkgs.u2c
      ];

      services.copyparty =
        let
          # TODO: this is kinda an implementation detail and might break
          stateDir = "/var/lib/copyparty";
        in
        {
          enable = true;
          inherit package user group;

          settings = {
            ### connection
            # e.g. boomerparty, featherparty
            name = "${config.networking.hostName}party";
            p = "80";
            z = true;
            no-robots = true;

            ah-alg = "argon2"; # hash passwords

            ### paths
            shr = "/shares";
            hist = stateDir;

            e2dsa = true; # enable indexing
            dedup = true;
            theme = 2; # monokai
            # just a normal spinner
            spinner = ",padding:0;border-radius:9em;border:.2em solid #444;border-top:.2em solid #fc0";

            forget-ip = 10080; # week, apparently to comply with GDPR

            ### tarball control
            zipmaxn = 200;
            zipmaxs = "8G";
            # don't download any compressed tarballs, zips are still allowed
            no-tarcmp = true;

            # useful if you have podcasts or whatever
            rss = true;

            # any messages from people with delete perms get notified
            xm = "ad,,${lib.getExe' pkgs.libnotify "notify-send"},hey,--";
            # notify on upload to host machine
            xau = "f,,${lib.getExe' pkgs.libnotify "notify-send"},copy,--";

            # according to docs: checks for dangerous symlinks on startup
            # I have symlinks to the nix store so this one isn't really possible
            # ls = "**,*,ln,p,r";
          };

          accounts.${user}.passwordFile = config.sops.secrets.copyparty.path;
          accounts.docs.passwordFile = config.sops.secrets.copyparty-weak.path;

          volumes =
            let
              access.A = [ user ];
            in
            {
              "/" = {
                inherit access;
                path = "/home/${user}";
                flags = {
                  hardlinkonly = true;
                  fk = 4;
                  # they call this "slightly faster" but forgot my home folder
                  # is HUGE
                  nodirsz = true;
                  # please support gitignore
                  noidx = lib.concatStringsSep "|" [
                    ''\.iso$''
                    ''^/home/${user}/\.''
                    ''^/home/${user}/repos''
                    ''^/home/${user}/projects''
                    ''.*/\.git/.*''
                    ''.*/\.jj/.*''
                    ''.*/\.direnv/.*''
                    ''.*/\.flox/.*''
                    ''.*/nix/store/.*''
                    ''.*/result.*''
                    ''.*/repl-result.*''
                  ];
                };
              };

              "/Music" = {
                path = "/home/${user}/Music";
                access = access // {
                  r = "*";
                };
                flags.e2ts = true;
              };

              "/Documents" = {
                path = "/home/${user}/Documents";
                access = access // {
                  rw = [ "docs" ];
                };
                flags.e2ts = true;
              };

              "/drop" = {
                access = access // {
                  # you can only see the files if you know exactly the path and
                  # the file key.
                  wG = "*";
                };
                path = "${stateDir}/copyparty/drop/";
                flags = {
                  hardlinkonly = true;
                  # adds some extra random stuff so the file is a little more
                  # "secret"
                  fka = 8;
                  # cannot download partial uploads
                  nopipe = true;
                  # sort uploads by date
                  # this one seems buggy
                  # rotf = "%Y-%m-%d";
                  # no thumbnails
                  dthumb = true;
                  # little less than a quarter
                  lifetime = 60 * 60 * 24 * 30 * 4;
                  # no more than 500 mb over 15 minutes
                  maxb = "500m,600";
                  # you do not get to choose the filename
                  rand = true;
                  # max 200 mb uploads
                  sz = "0-200m";
                  # always leave a little more than my system closure size
                  df = "20g";
                  # No XSS please
                  nohtml = true;
                };
              };
            };
        };

      systemd.services.copyparty =
        let
          sessionBus = "/run/user/${builtins.toString config.users.users.${user}.uid}/bus";
        in
        {
          serviceConfig = {
            # allow port < 2^10
            AmbientCapabilities = [ "CAP_NET_BIND_SERVICE" ];
            # allow notify-send to go on its quirky dbus business
            BindReadOnlyPaths = [
              "-/etc/machine-id"
              "-${sessionBus}"
            ];
            Environment = [ "DBUS_SESSION_BUS_ADDRESS=unix:path=${sessionBus}" ];
          };
        };
    };
}
