{ fetchpatch2, ... }: [
  # fix modular services
  (fetchpatch2 {
    url = "https://github.com/NixOS/nixpkgs/commit/979b6b58c3d421eefe520bb10e7cd1794ecabfdd.patch";
    excludes = [ "doc" ];
    hash = "sha256-t2/02DZw4Bn6W4C1BBDQZP3LoCuHkXjnb5lvJB8obTg=";
  })
  # nixos/forgejo-runner: init
  (fetchpatch2 {
    url = "https://github.com/NixOS/nixpkgs/commit/48f87539d9cfc5ca4f7f6913dfcf51d24e849fcb.patch";
    excludes = [ "nixos/doc" ];
    hash = "sha256-Gm7LIX1fZ36z0Q+5pUNFB1b0qIjvBYtkrIOHLIhUUwI=";
  })
]
