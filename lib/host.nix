{ lib }: with lib; {
  isDarwin = host: hasInfix "darwin" host.system;
  isLinux = host: hasInfix "linux" host.system;
}
