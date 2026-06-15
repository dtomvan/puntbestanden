{
  flake.modules.maid.profiles-plasma.kconfig.settings.powerdevilrc = {
    "Battery/Display" = {
      DimDisplayIdleTimeoutSec = 300; # 5 min
      DimDisplayWhenIdle = true;
      TurnOffDisplayIdleTimeoutSec = 480; # 8 min
    };
    "Battery/SuspendAndShutdown" = {
      AutoSuspendAction = 1; # sleep
      AutoSuspendIdleTimeoutSec = 600; # 10 min
    };
  };
}
