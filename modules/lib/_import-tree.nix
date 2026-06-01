lib:
let
  inherit (builtins)
    readDir
    attrNames
    concatMap
    ;

  listFilesRecursiveCond =
    dir: condition:
    let
      internalFunc =
        folder:
        let
          contents = readDir folder;
        in
        concatMap (
          filename:
          let
            # HACK: no dollar+bracket templating here, because that would be
            # the only reason I would need to escape this file when copypasted
            # in a bash heredoc, which I do in modules/top-level/flake-inputs.nix
            subpath = "/" + folder + "/" + filename;
            type = builtins.getAttr filename contents;
          in
          if condition { inherit filename type; } then
            if type == "regular" then
              [ subpath ]
            else if type == "directory" then
              internalFunc subpath
            else
              [ ]
          else
            [ ]
        ) (attrNames contents);
    in
    internalFunc dir;

  isNixFile =
    { filename, type }:
    (lib.hasSuffix ".nix" filename || type == "directory") && !lib.hasPrefix "_" filename;
in
dir: (listFilesRecursiveCond dir isNixFile)
