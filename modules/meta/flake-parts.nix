{ inputs, ... }:
{
  imports = [
    inputs.flake-file.flakeModules.default
    inputs.flake-parts.flakeModules.modules
  ];

  flake-file.inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    import-tree.url = "github:denful/import-tree";
    flake-file.url = "github:denful/flake-file";
  };

  flake-file.outputs = ''
    inputs: inputs.flake-parts.lib.mkFlake { inherit inputs; }
    (inputs.import-tree ./modules)
  '';

  text.readme.parts.dendritic = ''
    # Dendritic
    This repository uses the [dendritic](https://github.com/mightyiam/dendritic)
    pattern for monolithic, interconnected NixOS/HomeManager/Nixvim configs.
    Hence it also uses [flake.parts](https://flake.parts/). This might throw you
    off if you are new to nix and/or nix flakes. You've been warned!

    It is meant to make configurations more modular, flexible, and shareable
    though, so I encourage you to learn from it if you do so desire. If you
    understand flake.parts, all you need to know is that (almost) **every nix
    file in this tree is a flake.parts module**.

    Learn more about it (in order of, well, "deepness" or complexity):
      - https://flake.parts/
      - https://flake.parts/options/flake-parts-modules.html
      - https://github.com/mightyiam/dendritic
      - https://github.com/denful/import-tree/
      - https://github.com/denful/flake-file/
  '';
}
