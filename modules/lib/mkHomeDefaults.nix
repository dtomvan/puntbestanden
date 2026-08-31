{
  flake.lib.mkHomeDefaults =
    user:
    { config, lib, ... }:
    {
      home.username = lib.mkDefault user;
      home.homeDirectory = lib.mkDefault "/home/${user}";
      # create the fallback that NixOS also has so we don't error out when it wasn't explicitly set.
      home.stateVersion = lib.mkOptionDefault lib.trivial.release;
      sops.age.keyFile = lib.mkDefault "${config.home.homeDirectory}/.config/sops/age/keys.txt";
    };
}
