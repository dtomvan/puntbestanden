{
  # trace: evaluation warning: `boot.zfs.forceImportRoot` is using the default
  # value of `true`. It is highly recommended to set it to `false`, the new
  # default from 26.11 on, to reduce the risk of data loss. Alternatively, you
  # can silence this warning by explicitly setting it to `true`.
  flake.modules.nixos.profiles-base.boot.zfs.forceImportRoot = false;
}
