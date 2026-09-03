{
  flake-inputs.tree-sitter-fitch = {
    url = "git+https://git.toostveen.nl/tom/tree-sitter-fitch";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  flake.modules.nixvim.default = { config, inputs', ... }: {
    plugins.treesitter = {
      enable = true;
      settings.highlight.enable = true;
      grammarPackages = config.plugins.treesitter.package.allGrammars ++ [
        inputs'.tree-sitter-fitch.packages.default
      ];
    };
  };
}
