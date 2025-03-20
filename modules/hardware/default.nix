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
  cfg = config.karui.hardware;
in
{
  options.karui.hardware = {
    razer = mkEnableOption "razer hardware configuration";
    pen-input = mkEnableOption "graphic tablet configuration";
  };
  config = {
    # razer
    hardware.openrazer = mkIf (cfg.razer) {
      enable = true;
      users = [ "karui" ];
      keyStatistics = true;
    };
    # pen-input
    hardware.opentabletdriver = mkIf (cfg.pen-input) {
      enable = true;
      daemon.enable = true;
    };
  };
}
