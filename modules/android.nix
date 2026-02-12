{
  flake.modules.nixos.hosts-boomer =
    { pkgs, ... }:
    {
      users.groups.plugdev = { };
      users.users.tomvd.extraGroups = [
        "adbusers"
        "plugdev"
      ];
      services.udev.extraRules =
        let
          idVendor = "04e8";
          idProduct = "6860";
        in
        ''
          SUBSYSTEM=="usb", ATTR{idVendor}=="${idVendor}", MODE="[]", GROUP="adbusers", TAG+="uaccess"
          SUBSYSTEM=="usb", ATTR{idVendor}=="${idVendor}", ATTR{idProduct}=="${idProduct}", SYMLINK+="android_adb"
          SUBSYSTEM=="usb", ATTR{idVendor}=="${idVendor}", ATTR{idProduct}=="${idProduct}", SYMLINK+="android_fastboot"

          # reccommended by odin4
          SUBSYSTEM=="usb", ATTR{idVendor}=="04e8", MODE="0666", GROUP="plugdev"
        '';
      environment.systemPackages = with pkgs; [
        android-tools
        heimdall
      ];
      services.udev.packages = with pkgs; [ heimdall ];
    };
}
