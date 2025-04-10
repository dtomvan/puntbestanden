{
  lib,
  buildFirefoxXpiAddon,
}:
buildFirefoxXpiAddon {
  pname = "obsidian-web-clipper";
  version = "0.11.4";
  addonId = "clipper@obsidian.md";
  url = "https://github.com/obsidianmd/obsidian-clipper/releases/download/0.11.4/obsidian-web-clipper-0.11.4-firefox.zip";
  hash = "sha256-XiPtVs2kZEq6NL/GXSYVOukX8yQB1oOd0HoVEeYSDWI=";
  meta = with lib; {
    homepage = "https://obsidian.md/clipper";
    description = "Highlight and capture the web in your favorite browser. The official Web Clipper extension for Obsidian.";
    license = licenses.mit;
    sourceProvenance = with sourceTypes; [binaryBytecode];
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
