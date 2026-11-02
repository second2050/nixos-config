{ config, lib, ... }:
let
  dns = {
    tangled-knot = "git.tngl.karui.moe";
    tangled-spindle = "ci.tngl.karui.moe";
    tranquil-pds = "at.karui.moe";
  };
  dataDirs = "/var/www";
  secretDir = "/var/www/_secrets";
in
{
  services = {
    caddy.virtualHosts = {
      "${dns.tranquil-pds}" = {
        extraConfig = with config.services.tranquil-pds; ''
          encode gzip zstd
          reverse_proxy ${settings.server.host}:${toString settings.server.port}
        '';
      };
    };
    atticd = {
      enable = true;
      mode = "monolithic";
      environmentFile = "/etc/atticd.env";
      settings = {
        listen = "127.0.0.101:8080";
        allowed-hosts = [
          "attic.karui.moe"
          "attic.second2050.me"
          "youkai.second2050.me"
        ];
        api-endpoint = "https://attic.karui.moe/";
        chunking = {
          nar-size-threshold = 64 * 1024;
          min-size = 16 * 1024;
          avg-size = 16 * 1024;
          max-size = 256 * 1024;
        };
        compression.type = "zstd";
        garbage-collection.interval = "12 hours";
      };
    };
    tangled = {
      knot-rs = { };
      spindle = { };
    };
    tranquil-pds = {
      enable = true;
      environmentFiles = [ "${secretDir}/tranquil-pds.env" ];
      dataDir = "${dataDirs}/tranquil-pds";
      database.createLocally = true;
      settings = {
        frontend.enabled = true;
        server.hostname = dns.tranquil-pds;
      };
    };
  };
}
