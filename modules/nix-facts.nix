{
  flake-file.inputs.nix-facts = {
    url = "github:crertel/nix-facts";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  perSystem =
    { inputs', ... }:
    {
      devShells.nix-facts = inputs'.nix-facts.devShells.default;
    };
}
