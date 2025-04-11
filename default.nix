(import
  ./flake-compat.nix
  { src = ./.; }
).defaultNix.outputs.packages.${builtins.currentSystem}
