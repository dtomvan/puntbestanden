{ inputs, ... }: {
  perSystem =
    {
      system,
      pkgs,
      ...
    }:
    {
      packages = {
        # treefmt for nixpkgs contributors
        nixtreefmt =
          let
            inherit (inputs) nixpkgs;
            inherit (import "${nixpkgs}/ci" { inherit nixpkgs system; }) fmt;
          in
          pkgs.symlinkJoin {
            name = "nixtreefmt";
            paths = [ fmt.pkg ];
            postBuild = ''
              mv $out/bin/{,nix}treefmt
            '';
          };
      };
    };
}
