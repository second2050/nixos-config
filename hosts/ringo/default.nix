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
    desktop.enable = true;
    games = {
      enable = true;
      patch = true;
    };
    hardware.extra = true;
  };

  # networking options
  networking = {
    hostName = "ringo";
    hostId = "a0fb3fd3";
  };

  # host specific packages
  environment.systemPackages = [
    pkgs.asahi-bless
  ];

  # Initial NixOS Version, do *not* change.
  # For more information, see `man configuration.nix`
  # or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion
  system.stateVersion = "25.05"; # Did you read the comment?

}
