{
  lib,
  callPackage,
  buildFirefoxXpiAddon ? callPackage ../../lib/buildFirefoxXpiAddon.nix { },
}:
buildFirefoxXpiAddon rec {
  pname = "obsidian-web-clipper";
  version = "0.11.7";
  addonId = "clipper@obsidian.md";
  url = "https://github.com/obsidianmd/obsidian-clipper/releases/download/${version}/obsidian-web-clipper-${version}-firefox.zip";
  hash = "sha256-7VFgltPbsf4WgyZzukRk5elkPLNyLFWVwizNj0tXmII=";

  meta = with lib; {
    homepage = "https://obsidian.md/clipper";
    description = "Highlight and capture the web in your favorite browser. The official Web Clipper extension for Obsidian.";
    maintainers = with lib.maintainers; [ dtomvan ];
    license = licenses.mit;
    sourceProvenance = with sourceTypes; [ binaryBytecode ];
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
    platforms = platforms.all;
  };
}
