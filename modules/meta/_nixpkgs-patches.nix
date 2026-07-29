{ fetchpatch2, ... }: [
  # nixos/forgejo-runner: init
  (fetchpatch2 {
    url = "https://github.com/NixOS/nixpkgs/commit/48f87539d9cfc5ca4f7f6913dfcf51d24e849fcb.patch";
    excludes = [ "nixos/doc" ];
    hash = "sha256-Gm7LIX1fZ36z0Q+5pUNFB1b0qIjvBYtkrIOHLIhUUwI=";
  })
]
