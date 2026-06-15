{
  flake.modules.homeManager.jujutsu =
    {
      pkgs,
      lib,
      ...
    }:
    {
      home.packages = lib.map pkgs.lazy-app.override [
        {
          pkg = pkgs.go;
          exe = "gofmt";
        }
        { pkg = pkgs.ruff; }
        { pkg = pkgs.rustfmt; }
        { pkg = pkgs.shfmt; }
        { pkg = pkgs.taplo; }
      ];

      programs.mergiraf = {
        enable = true;
        enableGitIntegration = true;
        enableJujutsuIntegration = true;
      };
      programs.jujutsu = {
        settings = {
          fix.tools = {
            nixfmt = {
              command = [
                "nixfmt"
                "-"
              ];
              patterns = [ "glob:'**/*.nix'" ];
            };

            ruff = {
              command = [
                "ruff"
                "format"
                "-"
              ];
              patterns = [ "glob:'**/*.py'" ];
            };

            gofmt = {
              command = [ "gofmt" ];
              patterns = [ "glob:'**/*.go'" ];
            };

            shfmt = {
              command = [ "shfmt" ];
              patterns = [
                "glob:'**/*.sh'"
                "glob:'**/*.bash'"
              ];
            };

            rustfmt = {
              enabled = false;
              command = [
                "rustfmt"
                "--emit"
                "stdout"
              ];
              patterns = [ "glob:'**/*.rs'" ];
            };

            taplo = {
              command = [
                "taplo"
                "format"
              ];
              patterns = [ "glob:'**/*.toml'" ];
            };
          };
        };
      };
    };
}
