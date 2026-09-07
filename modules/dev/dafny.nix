{
  flake.modules.maid.profiles-workstation = { pkgs, ... }: { packages = [ pkgs.dafny ]; };
  flake.modules.nixvim.default.lsp.servers.dafny.enable = true;
}
