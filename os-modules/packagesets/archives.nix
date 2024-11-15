{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    unzip
    zip
    libarchive
    rar
    unrar
    bzip2
    lz4
    # Ooh spooky
    xz
  ];
}
