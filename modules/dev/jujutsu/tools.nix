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
          { pkg = nixfmt-rfc-style; }
          { pkg = rustfmt; }
          { pkg = ruff; }
          {
            pkg = go;
            exe = "gofmt";
          }
          { pkg = shfmt; }
          { pkg = taplo; }
        ];

      programs.mergiraf.enable = true;
      programs.jujutsu = {
        settings = {
          merge-tools = {
            mergiraf = {
              program = "mergiraf";
              merge-args = [
                "merge"
                "$base"
                "$left"
                "$right"
                "-o"
                "$output"
                "--fast"
              ];
              merge-conflict-exit-codes = [ 1 ];
              conflict-marker-style = "git";
            };
          };

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
