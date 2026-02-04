# Deploy-rs: refactor 

- STATE: OPEN
- PRIORITY: 50

> this is ugly, but yeah the API of deploy-rs doesn't seem really flexible to me. How to fix?
../../modules/top-level/deploy.nix
```nix
      legacyPackages.activationPackage =
        args:
        pkgs.buildEnv {
          name = "activatable-${args.profileName}";
          paths = [
            args.profile
            (self'.legacyPackages.activate args)
          ];
        };
```
