{ lib, ...}:
with lib;
rec {
	getDir = dir: mapAttrs
    (file: type:
      if type == "directory" then getDir "${dir}/${file}" else type
    )
    (builtins.readDir dir);
	files = dir: collect isString (mapAttrsRecursive (path: type: concatStringsSep "/" path) (getDir dir));
}
