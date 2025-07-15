{ inputs, ... }:
{
  flake.modules.nixos.nix-common =
    { lib, ... }:
    {
      nixpkgs.flake.setFlakeRegistry = true;
      nix.registry =
        (lib.mapAttrs
          # WHY can't this be key as indirect reference name then value as
          # a path, DONE
          (name: value: {
            from = {
              type = "indirect";
              id = name;
            };
            flake = value;
          })
          {
            inherit (inputs)
              disko
              localsend-rs
              nixpkgs-unfree
              nur
              vs2nix
              ;
          }
        )
        // {
          # loosey goosey dependency, it's fine though. always pull the latest
          # one please!
          templates = {
            from = {
              type = "indirect";
              id = "templates";
            };
            to = {
              owner = "dtomvan";
              repo = "templates";
              type = "github";
            };
          };
        };
    };
}
