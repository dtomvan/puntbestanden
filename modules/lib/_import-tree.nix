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
            subpath = folder + "/${filename}";
            type = contents.${filename};
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
