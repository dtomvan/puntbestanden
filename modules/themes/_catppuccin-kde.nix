{
  stdenvNoCC,
  fetchFromGitHub,
  colorScheme,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "catppuccin-kde";
  version = "0.2.6";

  src = fetchFromGitHub {
    owner = "catppuccin";
    repo = "kde";
    tag = "v${finalAttrs.version}";
    hash = "sha256-pfG0L4eSXLYLZM8Mhla4yalpEro74S9kc0sOmQtnG3w=";
  };

  postPatch = ''
    chmod +x **.sh
    patchShebangs .
    # we will not be using wget, unzip, or lookandfeeltool, so I won't
    # put it in the closure.
    sed -Ei -e '/^check_command_exists ".*"$/d' install.sh
  '';

  installPhase = ''
    runHook preInstall
      # mocha, peach, default decorations, only build colorscheme
      ./install.sh 1 7 1 color
      install -m644 ./dist/${colorScheme}.colors $out
    runHook postInstall
  '';
})
