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
        virtualHosts = {
          "${config.networking.fqdn}" = {
            serverAliases = cfg.cockpitAddresses;
            extraConfig = ''
              encode
              @denied not remote_ip private_ranges
              handle @denied {
                respond "you do not belong here..." 403
              }
              handle {
                reverse_proxy localhost:9090 {
                  transport http {
                    tls_insecure_skip_verify
                  }
                }
              }
            '';
          };
        };
        extraConfig = ''
          import caddy-extra
        '';
      };
      cockpit = {
        enable = true;
        plugins = with pkgs; [
          cockpit-files
          cockpit-podman
          cockpit-machines
        ];
        openFirewall = false;
        # fix cockpit localhost access... see: https://github.com/nixos/nixpkgs/issues/453337
        settings.WebService.Origins = lib.mkForce (
          toString (
            [
              "https://localhost"
              "https://${config.networking.fqdn}"
            ]
            ++ (map (x: "https://" + x) cfg.cockpitAddresses)
          )
        );
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
