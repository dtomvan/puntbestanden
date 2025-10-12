{
  flake.modules.nixos.virt-kvm =
    { pkgs, ... }:
    {
      environment.etc."libvirt/qemu.conf".text = "group=kvm";
      users.groups.libvirtd.members = [ "tomvd" ];
      virtualisation.spiceUSBRedirection.enable = true;
      virtualisation.libvirtd = {
        enable = true;
        qemu = {
          package = pkgs.qemu_kvm;
          runAsRoot = true;
          swtpm.enable = true;
        };
      };

      programs.virt-manager.enable = true;
    };
}
