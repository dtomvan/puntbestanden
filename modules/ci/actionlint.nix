# run actionlint all workflows in the flake
{
  perSystem =
    { pkgs, ... }:
    {
      checks.actionlint = pkgs.callPackage (
        {
          runCommand,
          actionlint,
          shellcheck,
        }:
        runCommand "actionlint-check"
          {
            nativeBuildInputs = [
              actionlint
              shellcheck
            ];
          }
          ''
            actionlint \
              -verbose \
              -shellcheck shellcheck \
              ${../../.github/workflows}/*

            touch $out
          ''
      ) { };
    };
}
