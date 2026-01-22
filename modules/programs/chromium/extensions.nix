{
  flake.modules.homeManager.programs-chromium =
    {
      pkgs,
      lib,
      config,
      ...
    }:
    {
      programs.chromium.extensions =
        let
          fetchExtension =
            {
              id,
              hash,
              version,
            }:
            {
              inherit id version;
              crxPath = pkgs.fetchurl {
                name = "${id}.crx";
                url = "https://clients2.google.com/service/update2/crx?response=redirect&acceptformat=crx2,crx3&prodversion=${lib.versions.major config.programs.chromium.package.version}&x=id%3D${id}%26installsource%3Dondemand%26uc";
                inherit hash;
              };
            };
        in
        [
          (fetchExtension {
            # ublock origin
            id = "cjpalhdlnbpafiamejdnhcphjbkeiagm";
            hash = "sha256-w4o5W5ZMUUXmCJ+R8z2e5mGfjGOxf22Yo1DYlE9Bal0=";
            version = "1.68.0";
          })
          (fetchExtension {
            # h264ify
            id = "aleakchihdccplidncghkekgioiakgal";
            hash = "sha256-IAe1nKZ0HU6VUrUfJaGQEAQafndQIM0K3XhgfXX43uw=";
            version = "2.0.1";
          })
          (fetchExtension {
            # keepassxc-browser
            id = "oboonakemofpalcgghocfoadofidjkkk";
            hash = "sha256-Xrpca6iyVN4okVLCQmrtn73dZYDP28S5LBMUX1Qz/nI=";
            version = "1.9.11";
          })
        ];
    };
}
