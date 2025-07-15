{
  import-tree,
  flake-parts,
  ...
}@inputs:
flake-parts.lib.mkFlake { inherit inputs; } (import-tree ./modules)
