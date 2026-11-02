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
    mkOption
    mkOverride
    ;
  cfg = config.karui.server;
in
{
  options.karui.server = {
    enable = mkEnableOption "karui’s server configuration";
    cockpitAddresses = mkOption {
      default = [ ];
    };
  };
  config = mkIf (cfg.enable) {
    virtualisation = {
      podman.enable = true;
    };
    services = {
      caddy = {
        enable = true;
        extraConfig = ''
          import caddy-extra
        '';
      };
      openssh.settings = {
        PasswordAuthentication = false;
      };
    };
    networking = {
      networkmanager.enable = mkOverride 900 false;
      useNetworkd = true;
      firewall = {
        allowedTCPPorts = [
          22 # ssh
          80 # caddy
          443 # caddy
        ];
        allowedUDPPorts = [
          80 # caddy
          443 # caddy
          62253 # wireguard
        ];
      };
      wg-quick.interfaces.wg0.configFile = "/etc/wireguard/wg0.conf";
    };
    systemd.network.enable = true;
  };
}
