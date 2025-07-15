{
  flake.modules.nixos.undollar =
    { pkgs, ... }:
    {
      environment.systemPackages = [
        (
          (pkgs.writeCBin "$"
            # c
            ''
              #include <unistd.h>

              int main(int argc, char *argv[]) {
                if (argc == 1)
                  return 0;
                return execvp(argv[1], &argv[1]);
              }
            ''
          ).overrideAttrs
          (prev: {
            name = "undollar-ng";

            # "tests"
            buildCommand =
              prev.buildCommand
              + ''
                [ "$($out/bin/\$)" == "" ]
                [ "$($out/bin/\$ pwd)" == "/build" ]
              '';
          })
        )
      ];
    };
}
