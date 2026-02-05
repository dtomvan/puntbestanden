{ inputs, ... }:
{
  flake-file.inputs.tasks = {
    url = "github:dtomvan/tasks.nvim";
    inputs.nixpkgs.follows = "nixpkgs";
  };
  flake.modules.nixvim.default = {
    imports = [ inputs.tasks.modules.nixvim.default ];
    plugins.tasks = {
      enable = true;
      settings.add_commands = true;
      withTelescope = true;
      withCmp = true;
    };
  };
}
