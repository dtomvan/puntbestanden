{
  perSystem =
    { pkgs, ... }:
    {
      packages.garnix-status = pkgs.writeShellApplication {
        name = "garnix-status";
        runtimeInputs = builtins.attrValues {
          inherit (pkgs)
            gitMinimal
            sops
            curl
            jq
            glow
            coreutils
            ;
        };
        inheritPath = false;
        runtimeEnv.queryFile =
          builtins.toFile "garnix-status.jq" # jq
            ''
              (.summary | (.failed + .cancelled + .pending)) as $notgreen
              | (.summary | "${
                builtins.replaceStrings [ "\n" ] [ "\\n" ] ''
                  # \(.branch)
                  ### Status
                  - **\(.succeeded)** succeeded
                  - **\(.failed)** failed
                  - **\(.pending)** pending
                  - **\(.cancelled)** cancelled
                  ### Packages
                ''
              }") as $summary
              | .builds | map("github:\(.repo_user)/\(.repo_name)/\(.git_commit)#\(.package_type)s.\(.system).\(.package)" as $flakeref 
                              | "- `\($flakeref)`: \(.status)"
                              )
              | join("\n")
              as $builds | "\($summary)\n\($builds)\n"
              | stderr
              | if $notgreen > 0 then halt_error(1) else empty end
            '';
        derivationArgs = {
          preferLocalBuild = true;
          allowSubstitutes = false;
        };
        text = ''
          commit="''${1:-$(git rev-parse HEAD)}"
          jwt="$(curl -XPOST --basic --user \
            "dtomvan:$(sops decrypt < ${../../secrets/garnix-token.secret})" \
            https://api.garnix.io/auth/jwt)"
          tmp="$(mktemp)"
          export tmp

          curl -sH "Authorization: Bearer $jwt" "https://api.garnix.io/commits/$commit" \
            | (jq -rf "''${queryFile:?}" 2>&1; echo $? > "$tmp") | glow -w 0

          code="$(< "$tmp")"
          rm "$tmp"

          exit "$code"
        '';
      };
    };

  flake.modules.nixos.profiles-workstation =
    { self', lib, ... }:
    {
      environment.systemPackages = lib.singleton self'.packages.garnix-status;
    };
}
