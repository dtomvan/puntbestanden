{ lib, config, ... }:
let
  inherit (lib)
    filterAttrs
    foldl
    listToAttrs
    mapAttrs
    mapAttrs'
    mapAttrsToList
    mergeAttrs
    mkIf
    nameValuePair
    ;

  knownHosts =
    config.hosts
    |> filterAttrs (_n: host: host ? sshPubkey.key)
    |> mapAttrs' (_n: host: nameValuePair host.hostName { publicKey = host.sshPubkey.key; });

  # TODO: this HAS to be able to be done in a more easier/elegant way??

  # explodes the combinations from allowedHosts and allowedUsers into a list of
  # attrsets in the form of { <hostname>.<username> = "<key>"; }
  explode = map (
    key:
    map (
      hostname:
      nameValuePair hostname (map (user: nameValuePair user [ key.key ]) key.allowedUsers |> listToAttrs)
    ) key.allowedHosts
    |> listToAttrs
  );

  # collects the output from `explode` into the final desired form, ready to be consumed by NixOS
  collect = foldl (
    acc: item:
    mapAttrs (
      hostname: users: mapAttrs (user: keys: ((acc.${hostname} or { }).${user} or [ ]) ++ keys) users
    ) item
    |> mergeAttrs acc
  ) { };

  # maps hostName to attrset in the form of:
  # { <username> = [ "key1" "key2" "key3" ]; };
  keysPerHost =
    config.hosts
    |> filterAttrs (_n: host: host.sshPubkey != null)
    |> mapAttrsToList (_n: host: host.sshPubkey)
    |> explode
    |> collect;
in
{
  config.flake.modules.nixos.services-ssh =
    { config, ... }:
    let
      # grabs the host's config by hostname from keysPerHost, and wraps it in
      # the correct nixos options under `users.users.<name>`
      maybeUserConfig = builtins.tryEval (
        mapAttrs (_n: keys: {
          openssh.authorizedKeys = { inherit keys; };
        }) keysPerHost.${config.networking.hostName} or { }
      );
    in
    {
      services.openssh.enable = true;
      programs.ssh = { inherit knownHosts; };
      users.users = mkIf (maybeUserConfig.success && maybeUserConfig.value != null) maybeUserConfig.value;
    };
}
