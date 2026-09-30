{ pkgs, ... }:
let
  inherit (pkgs.stdenv.hostPlatform) isLinux;
in
{
  home.packages =
    with pkgs;
    [
      doggo
      mtr
    ]
    ++ (
      if isLinux then
        [
          kemai
        ]
      else
        [ ]
    );
}
