{ inputs, ... }:
{
  flake-inputs.vscode-server = {
    url = "github:nix-community/nixos-vscode-server";
  };

  flake.modules.homeManager."tomvd@boomer" = {
    imports = [ inputs.vscode-server.homeModules.default ];
    services.vscode-server.enable = true;
  };
}
