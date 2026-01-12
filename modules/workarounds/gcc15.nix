{
  pkgs-overlays = [
    (
      _final: prev:
      let
        applyWorkaround =
          pname:
          prev.${pname}.overrideAttrs (oldAttrs: {
            env = (oldAttrs.env or { }) // {
              NIX_CFLAGS_COMPILE = (oldAttrs.env.NIX_CFLAGS_COMPILE or "") + " -std=gnu17";
            };
          });
      in
      {
        rogue = applyWorkaround "rogue";
        tome4 = applyWorkaround "tome4";
      }
    )
  ];
}
