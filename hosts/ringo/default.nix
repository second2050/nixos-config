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
  ];

  # setup device bootloader and kernel cmdline
  boot = {
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = false;
    kernelParams = [
      "apple_dcp.show_notch=1"
    ];
    extraModprobeConfig = ''
      options hid_apple fnmode=2
    '';
  };

  # hardware stuff
  hardware = {
    asahi = {
      peripheralFirmwareDirectory = pkgs.requireFile {
        name = "apple-silicon-firmware-ringo";
        url = "file:///boot/asahi";
        sha256 = "046ijbphv9lb2sqjzmqdi7gk53v3ws4qbinbpps48dd82inqjd27";
        hashMode = "recursive";
      };
    };
    graphics.enable = true;
    bluetooth.enable = true;
  };

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

  # Initial NixOS Version, do *not* change.
  # For more information, see `man configuration.nix`
  # or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion
  system.stateVersion = "25.05"; # Did you read the comment?

}
