{
  lib,
  pkgs,
  config,
  inputs,
  system,
  stdenv,
  fetchzip,
  fetchFromGithub,
  ...
}:
let
  inherit (lib) mkIf mkEnableOption mkDefault;
  cfg = config.karui.games;
in
{
  options.karui.games = {
    enable = mkEnableOption "karui’s game collection";
    patch = mkEnableOption "use customized game versions";
  };
  config = mkIf (cfg.enable) {
    nixpkgs.overlays = mkIf (cfg.patch) [
      (final: prev: {
        srb2kart = prev.srb2kart.overrideAttrs (old: {
          src = prev.fetchzip {
            url = "https://github.com/Indev450/SRB2Kart-Saturn/archive/5dfab42fcf787b5e76fdd204cbea6b2adb7ef65c.zip";
            hash = "sha256-JzlYT5V3glkoWzukgxs5wAGGe4+Qb9WeuKe2VMsENo4=";
          };
        });
      })
    ];
    environment.systemPackages = with pkgs; [
      srb2kart
      ringracers
      (prismlauncher.override {
        jdks = [
          graalvmPackages.graalvm-oracle
          graalvmPackages.graalvm-oracle_17
        ];
      })
    ];
  };
}
