{
  lib,
  pkgs,
  config,
  ...
}:
let
  inherit (lib) mkIf mkEnableOption;
  cfg = config.karui.games;
in
{
  options.karui.games = {
    enable = mkEnableOption "karui’s game collection";
  };
  config = mkIf (cfg.enable) {
    environment.systemPackages = with pkgs; [
      srb2kart
      srb2kart-saturn
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
