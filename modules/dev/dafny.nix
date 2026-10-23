{
  flake.modules.maid.profiles-workstation = { pkgs, ... }: { packages = [ pkgs.dafny ]; };
  flake.modules.nixvim.default = { pkgs, lib, ... }: {
    lsp.servers.dafny.enable = true;
    plugins.overseer.enable = true;
    extraConfigLuaPost = ''
      require("dafny").setup()
    '';
    extraPlugins =
      pkgs.vimUtils.buildVimPlugin {
        name = "dafny-nvim";
        src = pkgs.fetchFromGitHub {
          owner = "CameronBadman";
          repo = "dafny-nvim";
          rev = "94e5b204ff2312f96207ee259f54f787a68733b1";
          hash = "sha256-e/ndm/AURRZSGUL/slAkzri2XNcmCpz8fzQVI5ScXFI=";
        };
      }
      |> lib.singleton;
  };
}
