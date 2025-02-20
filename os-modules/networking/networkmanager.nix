{...}: {
  networking.networkmanager.enable = true;

	# KDE has a builtin applet
  # programs.nm-applet.enable = true;

  # networking.wireless.iwd.enable = true;
  # networking.networkmanager.wifi.backend = "iwd";
}
