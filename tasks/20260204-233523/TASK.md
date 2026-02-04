# deploy: enable deploy-rs.lib.deployChecks? 

- STATE: OPEN
- PRIORITY: 50

> this really bloats up a simple `nix flake check`. disabling it for now,
> despite how eager the docs are to not have me do that

```nix
checks = inputs.deploy-rs.lib.${system}.deployChecks self.deploy;
```
