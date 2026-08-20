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
  };

  # hardware stuff
  hardware = { };

  # enable modules
  karui = {
    base.enable = true;
    server.enable = true;
    vmHost.enable = true;
  };

  # networking options
  networking = {
    hostName = "youkai";
    hostId = "0874c3e4";
  };

  # hostnamed machine information
  environment.etc.machine-info = {
    text = ''
      ICON_NAME=server
      CHASSIS=server
    '';
    mode = "0440";
  };

  # host specific packages
  environment.systemPackages = [ ];

  # Initial NixOS Version, do *not* change.
  # For more information, see `man configuration.nix`
  # or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion
  system.stateVersion = "26.11"; # Did you read the comment?
}
