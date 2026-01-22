{ self, inputs, ... }:
{
  flake.modules.homeManager.programs-chromium =
    { pkgs, ... }:
    {
      programs.chromium = {
        enable = true;
        package = pkgs.ungoogled-chromium;
        nativeMessagingHosts = [ pkgs.kdePackages.plasma-browser-integration ];
        commandLineArgs = [
          "--disable-sandbox"
          "--ignore-gpu-blocklist"
        ];
      };
    };
  perSystem =
    { pkgs, ... }:
    let
      homeConfig = (
        inputs.home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = [
            self.modules.homeManager.programs-chromium
            {
              home = {
                stateVersion = "26.05";
                username = "tomvd";
                homeDirectory = "/home/tomvd";
              };
            }
          ];
        }
      );
    in
    {
      # trick to extract the wrapper from the config, will probably not work with extensions though
      packages = rec {
        my-chromium = homeConfig.config.programs.chromium.finalPackage;
        # for debugging/hashing purposes
        my-chromium-extensions = pkgs.linkFarmFromDrvs "my-chromium-extensions-${my-chromium.version}" (
          map (e: e.crxPath) homeConfig.config.programs.chromium.extensions
        );
        my-chromium-extensions-unpacked =
          pkgs.runCommand "my-chromium-extensions-unpacked-${my-chromium.version}"
            { nativeBuildInputs = [ pkgs.go-crx3 ]; }
            ''
              mkdir -p $out
              for extension in ${my-chromium-extensions}/*.crx; do
                crx3 unpack "$extension" -o $out
              done
            '';
        my-chromium-with-extensions = my-chromium.overrideAttrs (
          _final: prev: {
            # double wrapper, I know...
            buildCommand = prev.buildCommand + ''
              declare -a myextensions
              myextensions+=(${my-chromium-extensions-unpacked}/*)
              wrapProgram $out/bin/chromium \
                --add-flags "''${myextensions[*]/#/--load-extension=}"
            '';
          }
        );
      };
    };
}
