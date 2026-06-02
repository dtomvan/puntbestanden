{
  perSystem =
    { pkgs, ... }:
    let
      inherit (pkgs)
        writeShellApplication
        fetchurl
        jq
        skim
        wl-clipboard
        ;
    in
    {
      packages.emojipick = writeShellApplication {
        name = "emojipick";
        runtimeEnv.emojiList = fetchurl {
          url = "https://gist.githubusercontent.com/oliveratgithub/0bf11a9aff0d6da7b46f1490f86a71eb/raw/d8e4b78cfe66862cf3809443c1dba017f37b61db/emojis.json";
          hash = "sha256-5Zv18BTdx2nnM85BeOlNUz9Ridy1G77rc1avT13+gos=";
        };
        runtimeInputs = [
          jq
          skim
          wl-clipboard
        ];
        text = ''
          jq -c .emojis[] < "''${emojiList:?}" | sk --preview 'echo {} | jq .emoji' | jq -r .emoji | wl-copy
        '';
      };
    };
  flake.modules.nixos.profiles-workstation = { self', ... }: { environment.systemPackages = [ self'.packages.emojipick ]; };
}
