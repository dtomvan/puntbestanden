{
  pkgs,
  lib,
  ...
}:
{
  imports = [
    ../os/modules/services/ssh.nix
  ];

  nixpkgs.flake.setFlakeRegistry = true;
  nix = {
    settings = {
      experimental-features = lib.mkDefault [
        "nix-command"
        "flakes"
      ];
    };
    channel.enable = false;

    gc = {
      automatic = true;
      options = "--delete-older-than 14d";
    };
    optimise = {
      automatic = true;
    };
  };

  homebrew = {
    enable = true;
    casks = [
      "alacritty"
      "keybase"
    ];
  };

  environment.systemPackages = with pkgs; [
    gh
    git
    bat
    btop
    du-dust
    eza
    fastfetch
    fd
    file
    glow
    gron
    jq
    just
    neovim
    nixfmt-rfc-style
    nix-tree
    rink
    ripgrep
    skim
    tealdeer
    yazi
    nh
  ];

  networking.hostName = "autisme";
  networking.computerName = "Tom's Autisme";

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

  nixpkgs.hostPlatform = "x86_64-darwin";
  system.stateVersion = 6;
}
