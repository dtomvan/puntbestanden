{
  flake.modules.homeManager.programs-keepassxc = {
    xdg.autostart.enable = true;

    programs.keepassxc = {
      enable = true;
      autostart = true;
      # TODO: figure out what we can do about KeeShare (can we use sops with home-manager and then activate with a template??
      # settings = {
      #   General = {
      #     BackupBeforeSave = true;
      #     ConfigVersion = 2;
      #     MinimizeAfterUnlock = false;
      #   };
      #
      #   Browser.Enabled = true;
      #
      #   FdoSecrets.Enabled = true;
      #
      #   GUI = {
      #     ApplicationTheme = "dark";
      #     CompactMode = true;
      #     MinimizeOnClose = true;
      #     MinimizeOnStartup = false;
      #     MinimizeToTray = true;
      #     ShowExpiredEntriesOnDatabaseUnlock = false;
      #     ShowTrayIcon = true;
      #     TrayIconAppearance = "monochrome-light";
      #   };
      #
      #   Security = {
      #     ClearClipboardTimeout = 15;
      #     IconDownloadFallback = true;
      #     LockDatabaseIdleSeconds = 1800;
      #   };
      # };
    };
  };
}
