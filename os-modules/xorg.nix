{ pkgs, ... }: {
	services.xserver = {
		enable = true;
		displayManager.startx.enable = true;
		windowManager.afterstep.enable = true;
		modules = with pkgs; [
		xorg.xf86videonouveau
		];
	};
	environment.systemPackages = with pkgs; [
	plan9port
	emacs-nox
	rxvt-unicode
	];
}
