{ self, inputs, ... }:
{
  flake-file.inputs = {
    nixinate = {
      url = "github:matthewcroughan/nixinate";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  perSystem =
    { system, ... }:
    {
      apps = (inputs.nixinate.nixinate.${system} self).nixinate;
    };
}
