{pkgs ? (builtins.getFlake (builtins.toString ./../..)).outputs.pkgs, ...}:
pkgs.mkShell {
  packages = with pkgs; [
    tmux
    tmuxinator
    # We don't need any of this because ags already does almost everything through its transitive deps.
    # slim means no npm, we don't need it anyways
    # nodejs-slim_latest
    # we have nix!
    # nodePackages.eslint
    ags
    watchexec
  ];
  # see .tmuxinator.yml
  shellHook = ''
    tmuxinator
  '';
}
