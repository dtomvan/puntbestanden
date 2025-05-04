{
  pkgs,
  lib,
  ...
}:
{
  imports = [
    ../os/modules/users/tomvd.nix
    ../os/modules/services/ssh.nix
  ];

  users.users.tomvd.hashedPasswordFile = lib.mkForce null;
  users.users.tomvd.hashedPassword = "$y$j9T$w/zDDoj.X14G47Pg6Tdnk.$RcqndfuZdGUW1eMA2012j9ry0k/R4K/zBoxMRvEdyn6";

  environment.systemPackages = with pkgs; [
    gh
    git
    alacritty
  ];

  networking.hostName = "autisme";
  networking.computerName = "Tom's Autisme";

  homebrew = {
    enable = true;
    brews = [
    ];
    masApps = {
      Xcode = 497799835;
    };
  };

  system.defaults = {
    NSGlobalDomain = {
      AppleInterfaceStyle = "Dark";
      AppleShowAllExtensions = true;
      AppleShowAllFiles = true;
      AppleShowScrollBars = "Always";
      NSAutomaticSpellingCorrectionEnabled = false;
      NSAutomaticWindowAnimationsEnabled = false;
      NSScrollAnimationEnabled = false;
      NSUseAnimatedFocusRing = false;
    };
    finder = {
      AppleShowAllExtensions = true;
      AppleShowAllFiles = true;
    };
    dock.autohide = true;
    dock.static-only = true;
    loginwindow.autoLoginUser = "tomvd";
    universalaccess = {
      reduceMotion = true;
      reduceTransparency = true;
    };
  };

  system.activationScripts.tweaks.text = # bash
    ''
      sudo mdutil -i off -a
      sudo nvram boot-args="serverperfmode=1 $(nvram boot-args 2>/dev/null | cut -f 2-)"
      sudo defaults write /Library/Preferences/com.apple.loginwindow DesktopPicture ""
      defaults write com.apple.Accessibility DifferentiateWithoutColor -int 1
      defaults write com.apple.Accessibility ReduceMotionEnabled -int 1
      defaults write com.apple.loginwindow DisableScreenLock -bool true
    '';

  nix.gc.automatic = true;
}
