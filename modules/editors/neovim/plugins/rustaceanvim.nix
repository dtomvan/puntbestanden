{
  flake.modules.nixvim.default = {
    plugins.rustaceanvim = {
      enable = true;
      # TODO: this line may not be needed, as the plugin is self-proclaimed
      # lazy
      # lazyLoad.settings.ft = "rust";
    };

    # TODO: event parrern isn't supported...
    # keymapsOnEvents."FileType rust" =
    #   lib.mapAttrsToList
    #     (key: action: {
    #       inherit key;
    #       action = "<cmd>RustLsp ${action}<cr>";
    #       options.buffer = true;
    #     })
    #     {
    #       "<leader>a" = "codeAction";
    #       "K" = "hover actions";
    #       "[d" = "renderDiagnostic cycle_prev";
    #       "]d" = "hover cycle";
    #       "J" = "joinLines";
    #     };
  };
}
