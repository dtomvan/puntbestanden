{
  flake.modules.nixos.programs-gpg = {
    programs.gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };
  };
}
