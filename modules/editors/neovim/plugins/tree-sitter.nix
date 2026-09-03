{
  flake-inputs.tree-sitter-fitch = {
    url = "git+https://git.toostveen.nl/tom/tree-sitter-fitch";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  flake.modules.nixvim.default =
    { config, inputs', ... }:
    let
      tree-sitter-fitch = inputs'.tree-sitter-fitch.packages.default;
    in
    {
      plugins.treesitter = {
        enable = true;
        settings.highlight.enable = true;
        grammarPackages = config.plugins.treesitter.package.allGrammars ++ [ tree-sitter-fitch ];
        languageRegister.fitch = "fitch";
      };
    };
}
