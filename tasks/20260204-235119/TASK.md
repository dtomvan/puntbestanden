# firefox: only enable plasma-integration when on plasma

- STATE: OPEN
- PRIORITY: 50

> maybe only on plasma do this??

../../modules/programs/firefox/plasma-integration.nix

```nix
{
  flake.modules.homeManager.firefox =
    { pkgs, ... }:
    {
      config.programs.firefox = {
        nativeMessagingHosts = with pkgs; [ kdePackages.plasma-browser-integration ];
      };
    };
}
```

We don't have access to `osConfig` though, since we're doing standalone
home-manager. No idea how to fix. Maybe by declaring explicitly per host which
ones have plasma? But then what about other desktop environments?
