{ lib, ... }:
{
  # trace: evaluation warning: `boot.zfs.forceImportRoot` is using the default
  # value of `true`. It is highly recommended to set it to `false`, the new
  # default from 26.11 on, to reduce the risk of data loss. Alternatively, you
  # can silence this warning by explicitly setting it to `true`.
  flake.modules.nixos = {
    profiles-base.boot.zfs.forceImportRoot = false;

    # new option in unstable which gets a default with stateVersion >= 26.11,
    # which I don't (nessecarily) have (yet)
    # the option enables minio which is unmaintained. Hence the new default
    # will be false. Setting that explicitly.
    virt-incus.virtualisation.incus.bucketSupport = lib.mkDefault false;
  };
}
