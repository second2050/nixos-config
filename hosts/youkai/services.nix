{ ... }:
{
  services.atticd = {
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
}
