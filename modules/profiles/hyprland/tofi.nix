{
  flake.modules.homeManager.hyprland = {
    programs.tofi = {
      enable = true;
      settings = {
        terminal = "alacritty";
        text-cursor = true;
        font = "Afio";
        font-size = 12;
        outline-width = 0;
        border-width = 0;
        prompt-text = ": ";
        width = "50%";
        height = "30%";
        corner-radius = 20;
      };
    };
  };
}
