{ pkgs, ... }: {
	hardware.sane = {
		enable = true;
		extraBackends = with pkgs; [ hplip sane-airscan ipp-usb ];
	};
	# services.saned.enable = true;

	environment.systemPackages = with pkgs; [
		xsane
	];
}
