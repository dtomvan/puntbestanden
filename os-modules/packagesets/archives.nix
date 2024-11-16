{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    unzip
    zip
    libarchive
    rar
    bzip2
	zstd
    lz4
    # Ooh spooky
    xz
  ];
}
