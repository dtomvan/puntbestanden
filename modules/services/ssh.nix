{ lib, config, ... }:
let
  inherit (lib)
    filterAttrs
    foldl
    listToAttrs
    mapAttrs
    mapAttrs'
    mergeAttrs
    mkIf
    mkMerge
    nameValuePair
    ;

  knownHosts =
    config.hosts
    |> filterAttrs (_n: host: host ? sshPubkey.key)
    |> mapAttrs' (_n: host: nameValuePair host.networking.hostName { publicKey = host.sshPubkey.key; });

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
    |> builtins.attrValues
    |> builtins.filter (host: host.sshPubkey != null)
    |> map (host: host.sshPubkey)
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
      users.users = mkMerge [
        (mkIf (maybeUserConfig.success && maybeUserConfig.value != null) maybeUserConfig.value)
        {
          tomvd.openssh.authorizedKeys.keys = [
            # Nothing Phone (3a) key
            "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBO7XeCMqmJps9MSUI1g7UmMAKqsggo+XOjfO8P3zw16HON7eE/eMx8OZXhovfHXPEm+dxKjLyV3JepjH+JzPU3Q="
          ];
        }
      ];
    };
}
