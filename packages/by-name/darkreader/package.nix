{
  lib,
  callPackage,
  buildFirefoxXpiAddon ? callPackage ../../lib/buildFirefoxXpiAddon.nix { },
  buildNpmPackage,
  fetchFromGitHub,
}:
let
  xpifile = buildNpmPackage (finalAttrs: {
    pname = "darkreader";
    version = "4.9.105";

    src = fetchFromGitHub {
      owner = "darkreader";
      repo = "darkreader";
      rev = "v${finalAttrs.version}";
      hash = "sha256-fN/7n5qsQ3q0F73oHhhZS6V4ZJVUXMCWAp7WQYzNubU=";
    };

    npmDepsHash = "sha256-NamyPTm0bwXWcun5hYkNqrkJvzah3idTH1aFW51+S0Q=";
    npmBuildScript = "build:firefox";

    installPhase = ''
      runHook preInstall

      cp build/release/darkreader-firefox.xpi $out

      runHook postInstall
    '';
  });
in
buildFirefoxXpiAddon rec {
  inherit (xpifile) pname version;
  src = xpifile;

  addonId = "addon@darkreader.org";

  meta = {
    description = "Dark Reader Chrome and Firefox extension";
    homepage = "https://github.com/darkreader/darkreader";
    changelog = "https://github.com/darkreader/darkreader/blob/${version}/CHANGELOG.md";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
    mozPermissions = [
      "alarms"
      "contextMenus"
      "storage"
      "tabs"
      "theme"
      "<all_urls>"
    ];
  };
}
