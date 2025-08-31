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
      ];
      blockedInputs = [
        # fucks about with the 3 billion config classes they are handling
        "nixvim"
        # does flake-parts modules, which I don't support yet
        "nur"
        "nuschtos-search"
      ];
      blockedModules = [
        # broken
        "srvos.nixosModules.roles-github-actions-runner"
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
        scopes = lib.map (t: {
          inherit (t) name;
          modules = [ t.value ];
          # TODO: find a way to extract the source URL automatically, if it is
          # even possible
          urlPrefix = "https://google.com/?q=";
          inherit specialArgs;
        }) allFlatTypes;
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
          ${lib.getExe pkgs.live-server} -p ${builtins.toString port} ${search}
        '';
      };
    };
}
