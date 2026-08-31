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
    mkOverride
    ;
  cfg = config.karui.server;
in
{
  options.karui.server = {
    enable = mkEnableOption "karui’s server configuration";
  };
  config = mkIf (cfg.enable) {
    virtualisation = {
      podman.enable = true;
    };
    services.cockpit = {
      enable = true;
      plugins = with pkgs; [
        cockpit-files
        cockpit-podman
        cockpit-machines
      ];
      openFirewall = true;
    };
    networking = {
      networkmanager.enable = mkOverride 900 false;
      useNetworkd = true;
    };
    systemd.network.enable = true;
    services.openssh.settings = {
      PasswordAuthentication = false;
    };
  };
}
