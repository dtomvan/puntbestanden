{
  lib,
  mktemp,
  writers,
}:
writers.writeBashBin "json2nix" ''
  temp="$(${lib.getExe mktemp})"

  cleanup() {
      rm $temp
  }

  if (( $# > 0 )); then
      rm $temp
      temp=$1
  else
      cat > $temp
      trap cleanup EXIT
  fi

  nix --extra-experimental-features 'nix-command' \
      eval --impure \
      --expr "builtins.fromJSON (builtins.readFile $temp)"
''
