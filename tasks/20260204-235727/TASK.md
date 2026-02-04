# users-tomvd: move openssh keys elsewhere

- STATE: OPEN
- PRIORITY: 50

../../modules/profiles/base.nix

> this is required by services-ssh, remove explicit tomvd keys in there
```nix
{
  imports = with <...>; [ users-tomvd ];
}
```

We want it to be possible to import `services-ssh`, but *not* have `users-tomvd` imported.
