{ inputs, ... }:
{
  flake-file.inputs.direnv-instant = {
    url = "github:Mic92/direnv-instant";
    inputs.nixpkgs.follows = "nixpkgs";
  };
  flake.modules.homeManager.basic-cli =
    { pkgs, lib, ... }:
    {
      home.packages = [ inputs.direnv-instant.packages.${pkgs.stdenv.hostPlatform.system}.default ];
      programs.bash.initExtra = lib.mkAfter ''
        eval "$(direnv-instant hook bash)"
      '';
    };
}
