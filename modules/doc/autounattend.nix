{
  config,
  ...
}:
let
  cfg = config.autounattend;
in
{
  text.readme.parts.autounattend =
    # markdown
    ''
      # Autounattend
      This repository includes an "autounattend" installer ISO, which:
      - Installs a nested, pre-defined NixOS configuration
      - Without any user interaction required apart from booting it
      - Also automatically partitions through disko
      - Does not require internet

      To create the iso, run `nix build .#${cfg.isoTarget}`.

      To run an install demo in QEMU, run `nix run .#${cfg.demoTarget}`.

      If you do not have access to the secrets in this repo you'll need to
      comment out the `networking-wifi-passwords` import in order to build it.

      Beware: the eval time (and disk usage) is very inefficient, because it
      seems like nix wants to copy around some `source` directory through the
      store a couple of times. it is a cool party trick though.
    '';

  perSystem.devshells.default.commands = [
    {
      name = "iso";
      help = "build the autounattend iso";
      command = "nix build .#${cfg.isoTarget}";
    }
  ];
}
