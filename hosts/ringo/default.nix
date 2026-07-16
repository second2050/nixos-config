# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{
  config,
  lib,
  pkgs,
  self,
  ...
}:

{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  # setup device bootloader and kernel cmdline
  boot = {
    kernelPackages = lib.mkForce pkgs.linux-asahi-fairydust;
    loader.systemd-boot = {
      enable = true;
      consoleMode = lib.mkForce "max"; # override 2022 workaround from nixos-apple-silicon
    };
    loader.efi.canTouchEfiVariables = false;
    kernelParams = [
      "appledrm.show_notch=1"
      "zswap.enabled=1"
      "zswap.compressor=zstd"
      "zswap.max_pool_percent=50"
      "zswap.shrinker_enabled=1"
    ];
    extraModprobeConfig = ''
      options hid_apple fnmode=2
    '';
  };

  # hardware stuff
  hardware = {
    asahi = {
      peripheralFirmwareDirectory = pkgs.requireFile {
        name = "apple-silicon-vendorfw-ringo";
        url = "file:///boot/vendorfw";
        sha256 = "04a3h5fsbwf0dhsgnr2kpppsxad89gamks0yjg83i6gqdbz2b5di";
        hashMode = "recursive";
      };
    };
    graphics.enable = true;
    bluetooth.enable = true;
  };

  # swap configuration
  # using zswap because of low ram
  zramSwap.enable = false;
  swapDevices = [
    {
      device = "/var/lib/swapfile";
      size = 16 * 1024;
    }
  ];

  # enable modules
  karui = {
    base.enable = true;
    desktop = {
      enable = true;
      autoLogin = true;
    };
    games.enable = false;
    hardware.extra = true;
    vmHost.enable = true;
  };

  # networking options
  networking = {
    hostName = "ringo";
    hostId = "a0fb3fd3";
  };

  # host specific packages
  environment.systemPackages = with pkgs; [
    asahi-bless
  ];

  # asahi specific substituter
  nix.settings = {
    extra-substituters = [
      "https://nixos-apple-silicon.cachix.org"
    ];
    extra-trusted-public-keys = [
      "nixos-apple-silicon.cachix.org-1:8psDu5SA5dAD7qA0zMy5UT292TxeEPzIz8VVEr2Js20="
    ];
  };

  # machine information
  environment.etc.machine-info = {
    text = ''
      ICON_NAME=laptop
      CHASSIS=laptop
    '';
    mode = "0440";
  };

  home-manager.users.${config.karui.base.user.username}.imports = [
    "${self}/homeModules/work"
  ];

  # Initial NixOS Version, do *not* change.
  # For more information, see `man configuration.nix`
  # or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion
  system.stateVersion = "25.05"; # Did you read the comment?

}
