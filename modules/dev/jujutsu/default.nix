# { config, ... }:
{
  flake.modules.homeManager.jujutsu = {
    # imports = with config.flake.modules.homeManager; [
    #   git
    # ];
    #
    programs.jujutsu.enable = true;
  };
}
