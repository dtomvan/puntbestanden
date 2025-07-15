{
  flake.modules.homeManager.plasma = {
    programs.plasma = {
      powerdevil.battery = {
        dimDisplay = {
          enable = true;
          idleTimeout = 300; # 5 minutes
        };
        turnOffDisplay = {
          idleTimeout = 480; # 8 minutes
        };
        autoSuspend = {
          action = "sleep";
          idleTimeout = 600; # 10 minutes
        };
      };
    };
  };
}
