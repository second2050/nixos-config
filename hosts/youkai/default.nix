# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{
  pkgs,
  inputs,
  lib,
  ...
}:

{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ./services.nix
  ];

  # setup device bootloader and kernel cmdline
  boot = {
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = false;
  };

  # hardware stuff
  hardware = { };

  # enable modules
  karui = {
    base.enable = true;
    server.enable = true;
  };

  # networking options
  networking = {
    hostName = "youkai";
    hostId = "0874c3e4";
    interfaces = {
      ens18 = {
        ipv6.addresses = [
          {
            address = "2a14:d107:1:c::2051";
            prefixLength = 64;
          }
        ];
      };
    };
    defaultGateway6 = {
      address = "2a14:d107:1:c::1";
      interface = "ens18";
    };
  };
  services.resolved = {
    enable = true;
    settings.Resolve = {
      Cache = "no-negative";
      DNSSEC = "false";
      DNSOverTLS = "opportunistic";
      DNS = [
        "2001:4860:4860::6464#dns64.dns.google"
        "2001:4860:4860::64#dns64.dns.google"
      ];
      FallbackDNS = [
        "2620:fe::fe#dns.quad9.net"
        "2620:fe::9#dns.quad9.net"
      ];
    };
  };

  # host specific packages
  environment.systemPackages = [ ];
  programs.nh = {
    clean.enable = true;
    flake = "github:second2050/nixos-config";
  };

  # Initial NixOS Version, do *not* change.
  # For more information, see `man configuration.nix`
  # or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion
  system.stateVersion = "26.11"; # Did you read the comment?
}
