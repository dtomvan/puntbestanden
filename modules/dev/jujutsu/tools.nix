{
  flake.modules.homeManager.jujutsu =
    {
      pkgs,
      lib,
      ...
    }:
    {
      home.packages =
        with pkgs;
        lib.map pkgs.lazy-app.override [
          {
            pkg = go;
            exe = "gofmt";
          }
          { pkg = ruff; }
          { pkg = rustfmt; }
          { pkg = shfmt; }
          { pkg = taplo; }
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
              command = [ "nixfmt" ];
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
