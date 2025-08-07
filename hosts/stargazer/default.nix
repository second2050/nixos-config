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
    kernelPackages = pkgs.linuxPackages_xanmod_latest;
  };

  # hardware stuff
  hardware = {
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
    hostName = "stargazer";
    hostId = "fa3b5ac2";
  };

  # hostnamed machine information
  environment.etc.machine-info = {
    text = ''
      ICON_NAME=desktop
      CHASSIS=desktop
    '';
    mode = "0440";
  };

  # host specific packages
  environment.systemPackages = [
  ];

  # Initial NixOS Version, do *not* change.
  # For more information, see `man configuration.nix`
  # or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion
  system.stateVersion = "25.11"; # Did you read the comment?
}
