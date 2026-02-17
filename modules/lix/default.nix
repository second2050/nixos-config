{
  lib,
  pkgs,
  config,
  ...
}:
let
  inherit (lib)
    mkEnableOption
    mkIf
    ;
  cfg = config.karui.lix;
in
{
  options.karui.lix = {
    enable = mkEnableOption "replace CppNix with Lix";
  };
  config = mkIf (cfg.enable) {
    nixpkgs.overlays = [
      (final: prev: {
        inherit (prev.lixPackageSets.latest)
          nixpkgs-review
          nix-eval-jobs
          nix-fast-build
          colmena
          ;
      })
    ];

    nix.package = pkgs.lixPackageSets.latest.lix;
  };
}
