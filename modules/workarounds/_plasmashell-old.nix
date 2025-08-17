# https://github.com/NixOS/nixpkgs/issues/126590#issuecomment-2860616947
let
  plasmashell-workaround = _final: prev: {
    kdePackages = prev.kdePackages // {
      plasma-workspace =
        let
          unwrapped = prev.kdePackages.plasma-workspace;
        in
        prev.stdenv.mkDerivation {
          inherit (unwrapped) pname version;

          buildInputs = [ unwrapped ];
          nativeBuildInputs = [ prev.makeWrapper ];

          dontUnpack = true;
          dontWrapQtApps = true;
          dontFixup = true;

          installPhase = ''
            # remove duplicates in XDG_DATA_DIRS to speed up the copy process
            export XDG_DATA_DIRS="$(awk -v RS=: '{ if (!arr[$0]++) { printf("%s%s", !ln++ ? "" : ":", $0) }}' <<< "$XDG_DATA_DIRS")"

            # copy output from base package and make it writable
            cp -r ${unwrapped} $out
            chmod u+w $out $out/bin $out/bin/plasmashell

            # copy all XDG_DATA_DIRS into a single directory
            ( IFS=:
              mkdir $out/xdgdata
              for DIR in $XDG_DATA_DIRS; do
                if [[ -d "$DIR" ]]; then
                  cp -r $DIR/. $out/xdgdata/
                  chmod -R u+w $out/xdgdata
                fi
              done
            )

            # create a wrapper script that replaces the original XDG_DATA_DIRS with the
            # newly created directory and then calls the original plasmashell binary
            makeWrapper ${unwrapped}/bin/.plasmashell-wrapped $out/bin/plasmashell \
              --set XDG_DATA_DIRS "$out/xdgdata:/run/current-system/sw/share"
          '';

          passthru = { inherit (unwrapped.passthru) providedSessions; };
        };
    };
  };
in
{
  flake.overlays = { inherit plasmashell-workaround; };
}
