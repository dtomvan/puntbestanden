{ self, inputs, ... }:
{
  perSystem =
    { system, lib, ... }:
    let
      # same-name package would result into infinite recursion otherwise
      pkgs = inputs.nixpkgs.legacyPackages.${system};
      configs =
        class:
        (lib.mapAttrsToList (n: _: {
          display = "${class} ${n}";
          path = "${class}Configurations.${n}";
        }) self."${class}Configurations");
      packages =
        class:
        (lib.mapAttrsToList (n: _: {
          display = "${class} ${n}";
          path = "${class}.x86_64-linux.${n}";
        }) self."${class}".x86_64-linux);
      bookmarks = pkgs.writers.writeJSON "nix-inspect.json" {
        bookmarks =
          lib.concatMap configs [
            "nixos"
            "home"
          ]
          ++ lib.concatMap packages [
            "nixvimConfigurations"
            "packages"
          ];
      };
    in
    {
      packages.nix-inspect = pkgs.symlinkJoin {
        name = "${pkgs.nix-inspect.name}-wrapped";
        paths = [ pkgs.nix-inspect ];
        nativeBuildInputs = [ pkgs.makeWrapper ];
        postBuild = ''
          install -Dm444 ${bookmarks} $out/config/nix-inspect/config.json
          wrapProgram $out/bin/nix-inspect \
            --set XDG_CONFIG_HOME $out/config
        '';
      };
    };

  flake.modules.nixos.profiles-base =
    { pkgs, ... }:
    {
      environment.systemPackages = [ self.packages.${pkgs.stdenv.hostPlatform.system}.nix-inspect ];
    };
}
