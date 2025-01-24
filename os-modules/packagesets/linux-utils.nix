{ pkgs, ... }: {
	environment.systemPackages = with pkgs; [
	usbutils
	pciutils
	e2fsprogs
	btrfs-progs
	util-linux
	dosfstools
	];
}
