# { self, ... }:
{
  flake.modules.homeManager.jujutsu = {
    # imports = with self.modules.homeManager; [
    #   git
    # ];
    #
    programs.jujutsu.enable = true;
  };
}
