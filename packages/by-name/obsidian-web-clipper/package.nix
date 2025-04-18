# WARNING: if you want to use an addon that was packaged from source, you need
# FF dev edition or it won't work as it's unsigned.
{
  fetchFromGitHub,
  lib,
  buildNpmPackage,
  callPackage,
  buildFirefoxXpiAddon ? callPackage ../../lib/buildFirefoxXpiAddon.nix {},
}: let
xpifile = buildNpmPackage (finalAttrs: {
  pname = "obsidian-web-clipper.zip";
  version = "0.11.4";

  src = fetchFromGitHub {
    owner = "obsidianmd";
    repo = "obsidian-clipper";
    rev = finalAttrs.version;
    hash = "sha256-3MnvOwBvM46YLBTPGDdxJ5yCPLsQtQFLqJwdJa1Czkc=";
  };

  npmDepsHash = "sha256-09jlRGOzcvhkLB7ebpXwg1nBi+Xjer9HWmftoYyvqHM=";
  npmBuildScript = "build:firefox";

  installPhase = ''
    runHook preInstall

    cp builds/obsidian-web-clipper-${finalAttrs.version}-firefox.zip $out

    runHook postInstall
  '';
}); in
buildFirefoxXpiAddon {
  pname = "obsidian-web-clipper";
  version = xpifile.version;
  addonId = "clipper@obsidian.md";

  src = xpifile;
  meta = with lib; {
    homepage = "https://obsidian.md/clipper";
    description = "Highlight and capture the web in your favorite browser. The official Web Clipper extension for Obsidian.";
    license = licenses.mit;
    mozPermissions = [
      "activeTab"
      "clipboardWrite"
      "contextMenus"
      "storage"
      "scripting"
      "<all_urls>"
      "http://*/*"
      "https://*/*"
    ];
  };
}

# vim:sw=2 ts=2 sts=2
