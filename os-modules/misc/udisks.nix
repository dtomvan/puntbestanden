{ pkgs, config, ... }: {
	services.udisks2.enable = true;
	programs.gnome-disks.enable = true;

	environment.systemPackages = with pkgs; [nautilus];
}
