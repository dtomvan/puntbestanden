{
  config,
  pkgs,
  lib,
  ...
}: {
  programs.bash.initExtra = ''
    jc141()
    {
    	distrobox enter --root jc141-arch --additional-flags "--env VK_DRIVER_FILES=/usr/share/vulkan/icd.d/nvidia_icd.json" -- bash "$@"
    	distrobox stop jc141-arch
    }

  '';
}
