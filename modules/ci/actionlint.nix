# run actionlint all workflows in the flake
{
  perSystem =
    { pkgs, ... }:
    {
      checks.actionlint =
        pkgs.runCommandLocal "actionlint-check"
          {
            nativeBuildInputs = with pkgs; [
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
          '';
    };
}
