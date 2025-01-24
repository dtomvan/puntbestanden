{
  pkgs,
  lib,
  config,
  ...
}: let
  writeBash = pkgs.writers.writeBash;
  locker = writeBash "hypr-lock.sh" ''
    pgrep swaylock || ${pkgs.swaylock-effects}/bin/swaylock -eFf -C ~/.config/hypr/swaylock.cfg "$@"
  '';

  hyprctl-env = writeBash "env.bash" (builtins.readFile ./env.bash);
in {
  inherit locker hyprctl-env;

  playerctl = lib.getExe pkgs.playerctl;
  wpctl = "${pkgs.wireplumber}/bin/wpctl";
  grimblast = lib.getExe pkgs.grimblast;
  bemenu = lib.getExe pkgs.bemenu;
  tofi = rec {
    normal = lib.getExe pkgs.tofi;
    run = normal + "-run";
    drun = normal + "-drun";
  };
  wl-paste = "${pkgs.wl-clipboard}/bin/wl-paste";
  clipman = lib.getExe pkgs.clipman;
  ags = lib.getExe pkgs.ags;
  # agsv1 = "${pkgs.agsv1}/bin/agsv1";

  desktop-alpha = writeBash "desktop-alpha.sh" ''
    source ${hyprctl-env}

    set -x

    wsc=
    getwsclients wsc

    for i in $wsc; do
        hb setprop "address:$i" alpha "$1" lock\; \
           setprop "address:$i" alphainactive "$1" lock
    done
  '';

  toggle-nightlight = writeBash "toggle-nightlight.sh" ''
    source ${hyprctl-env}
    currentshader=$(h getoption decoration:screen_shader -j | ${lib.getExe pkgs.jq} -r '.str')

    if [[ "$currentshader" != *"bluelight.frag" ]]; then
        h keyword decoration:screen_shader ~/.config/hypr/bluelight.frag
    else
        h keyword decoration:screen_shader ""
        h reload
    fi
  '';

  swayidle = writeBash "swayidle.sh" ''
    ${lib.getExe pkgs.swayidle} -w                                                                         \
    timeout 290 'pgrep swaylock || hyprctl notify 2 10000 0 "Locking in 10 seconds..."' \
    timeout 300 ${locker}                                                               \
    timeout 600 'hyprctl dispatch dpms off'                                             \
    resume 'hyprctl dispatch dpms on'                                                   \
    before-sleep ${locker}
  '';
}
