{ pkgs, host, lib, ... }: {
	hardware.sane = {
		enable = true;
		extraBackends = with pkgs; [ hplip sane-airscan ipp-usb ];
	};

	environment.systemPackages = lib.optional host.os.wantsKde pkgs.kdePackages.skanpage;
}
