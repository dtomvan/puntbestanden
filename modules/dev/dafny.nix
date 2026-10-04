{
  flake.modules.maid.profiles-workstation = { pkgs, ... }: {
    packages = [
      pkgs.dafny
      pkgs.z3
      pkgs.dotnet-runtime_8 # for dafny in vscode
    ];
  };
  flake.modules.nixvim.default = {
    lsp.servers.dafny.enable = true;
    plugins.overseer.enable = true;
  };
}
