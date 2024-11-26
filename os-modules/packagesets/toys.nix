{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    cava
    cbonsai
    cmatrix
    fortune
    neofetch
    pipes
    sl
    toilet
    wtf
    cowsay
  ];
}
