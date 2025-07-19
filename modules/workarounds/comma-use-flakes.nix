let
  patch = builtins.toFile "0001-feat-switch-from-nix-env-to-nix3-profile.patch" ''
    From 664bea4bdff3c1fe0ceb978baedc6e867b8c3f0d Mon Sep 17 00:00:00 2001
    From: Tom van Dijk <18gatenmaker6@gmail.com>
    Date: Sat, 19 Jul 2025 19:52:13 +0200
    Subject: [PATCH] feat: switch from nix-env to nix3-profile

    ---
     src/main.rs | 4 ++--
     1 file changed, 2 insertions(+), 2 deletions(-)

    diff --git a/src/main.rs b/src/main.rs
    index cdd04a0..8fdd8e8 100644
    --- a/src/main.rs
    +++ b/src/main.rs
    @@ -324,8 +324,8 @@ fn main() -> ExitCode {
             .contains("nixpkgs=");
     
         if args.install {
    -        let _ = Command::new("nix-env")
    -            .args(["-f", "<nixpkgs>", "-iA", basename])
    +        let _ = Command::new("nix")
    +            .args(["profile", "install", format!("nixpkgs#{basename}").as_str()])
                 .exec();
         } else if args.shell {
             // TODO: use cache here, but this is tricky since it actually depends in `nix-shell`
    -- 
    2.50.0

  '';

  overlay = _final: prev: {
    comma = prev.comma.overrideAttrs {
      patches = (prev.comma.patches or [ ]) ++ [
        patch
      ];
    };
  };
in
{
  debug = true;
  pkgs-overlays = [ overlay ];
}
