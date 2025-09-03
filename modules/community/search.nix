# Search through flake inputs' modules' options with a desktop shortcut
# TODO:
# - support modules.*
# - support more config classes like nixvim and flake
# - make it configurable
{
  inputs,
  lib,
  ...
}:

{
  flake-file.inputs = {
    nuschtos-search = {
      url = "github:NuschtOS/search";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  flake.modules.nixos.nuschtos-search =
    specialArgs@{ pkgs, config, ... }:
    let
      # I present: write-only nix code......
      types = [
        "nixosModules"
        "homeModules"
        "homeManagerModules"
      ];
      blockedInputs = [
        # does flake-parts modules, which I don't support yet
        "nur"
        # fucks about with the 3 billion config classes they are handling
        "nixvim"
        "nuschtos-search"
      ];
      blockedModules = [
        # deprecated, throws
        "nur.nixosModules.nur"
        # broken
        "nix-flatpak.homeManagerModules.nix-flatpak"
        "srvos.nixosModules.roles-github-actions-runner"
        "srvos.modules.nixos.roles-github-actions-runner"
      ];

      port = 6969;

      flattenTypes = types: lib.concatLists (lib.map lib.attrsToList types);
      getTypes =
        ty: input:
        lib.mapAttrs' (name: value: lib.nameValuePair "${input}.${ty}.${name}" value) (
          inputs.${input}.${ty} or { }
        );
      getFlatTypes = input: flattenTypes (lib.map (ty: getTypes ty input) types);

      inputNames = lib.subtractLists blockedInputs (lib.attrNames inputs);
      allFlatTypes = lib.pipe inputNames [
        (lib.map getFlatTypes)
        lib.concatLists
        (lib.filter (i: !(lib.elem i.name blockedModules)))
      ];

      search = inputs.nuschtos-search.packages.${pkgs.stdenv.hostPlatform.system}.mkMultiSearch {
        title = "Search for puntbestanden on ${config.networking.hostName}";
        scopes = lib.map (
          t:
          (
            if lib.hasInfix ".homeManagerModules." t.name then
              {
                optionsJSON =
                  let
                    eval = inputs.home-manager.lib.homeManagerConfiguration {
                      inherit pkgs;
                      modules = [
                        t.value
                        {
                          home.stateVersion = "25.05";
                          home.username = "someuser";
                          home.homeDirectory = "/home/someuser";
                        }
                      ];
                    };
                    doc = pkgs.nixosOptionsDoc {
                      inherit (eval) options;
                      warningsAreErrors = false;
                    };
                  in
                  "${doc.optionsJSON}/share/doc/nixos/options.json";
              }
            else
              # hopefully nixos module
              {
                modules = [ t.value ];
                inherit specialArgs;
              }
          )
          // {
            inherit (t) name;
            urlPrefix = "https://google.com/?q=";
          }
        ) allFlatTypes;
      };
    in
    {
      environment.systemPackages = [
        (pkgs.makeDesktopItem {
          desktopName = "NüschtOS Search";
          name = "nuschtos-search";
          comment = "Search through all flake inputs on this device";
          exec = "${lib.getExe' pkgs.xdg-utils "xdg-open"} http://127.0.0.1:${builtins.toString port}";
          categories = [ "Utility" ];
        })
      ];

      systemd.services.nuschtos-server = {
        wantedBy = [ "graphical.target" ];
        after = [ "network.target" ];
        script = ''
          ${lib.getExe pkgs.python3} -m http.server -d ${search} ${builtins.toString port}
        '';
      };
    };
}
