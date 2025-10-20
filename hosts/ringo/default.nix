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
    games.enable = true;
    hardware.extra = true;
  };

  # networking options
  networking = {
    hostName = "ringo";
    hostId = "a0fb3fd3";
  };

  # host specific packages
  environment.systemPackages = with pkgs; [
    asahi-bless
    fex
    muvm
  ];

  # x86 support
  boot.binfmt.registrations = {
    i386-linux = {
      interpreter = "${pkgs.muvm}/bin/muvm --";
      wrapInterpreterInShell = true;
      magicOrExtension = ''\x7fELF\x01\x01\x01\x00\x00\x00\x00\x00\x00\x00\x00\x00\x02\x00\x03\x00'';
      mask = ''\xff\xff\xff\xff\xff\xfe\xfe\x00\xff\xff\xff\xff\xff\xff\xff\xff\xfe\xff\xff\xff'';
    };
    i486-linux = {
      interpreter = "${pkgs.muvm}/bin/muvm --";
      wrapInterpreterInShell = true;
      magicOrExtension = ''\x7fELF\x01\x01\x01\x00\x00\x00\x00\x00\x00\x00\x00\x00\x02\x00\x06\x00'';
      mask = ''\xff\xff\xff\xff\xff\xfe\xfe\x00\xff\xff\xff\xff\xff\xff\xff\xff\xfe\xff\xff\xff'';
    };
    i586-linux = {
      interpreter = "${pkgs.muvm}/bin/muvm --";
      wrapInterpreterInShell = true;
      magicOrExtension = ''\x7fELF\x01\x01\x01\x00\x00\x00\x00\x00\x00\x00\x00\x00\x02\x00\x06\x00'';
      mask = ''\xff\xff\xff\xff\xff\xfe\xfe\x00\xff\xff\xff\xff\xff\xff\xff\xff\xfe\xff\xff\xff'';
    };
    i686-linux = {
      interpreter = "${pkgs.muvm}/bin/muvm --";
      wrapInterpreterInShell = true;
      magicOrExtension = ''\x7fELF\x01\x01\x01\x00\x00\x00\x00\x00\x00\x00\x00\x00\x02\x00\x06\x00'';
      mask = ''\xff\xff\xff\xff\xff\xfe\xfe\x00\xff\xff\xff\xff\xff\xff\xff\xff\xfe\xff\xff\xff'';
    };
    x86_64-linux = {
      interpreter = "${pkgs.muvm}/bin/muvm --";
      wrapInterpreterInShell = true;
      magicOrExtension = ''\x7fELF\x02\x01\x01\x00\x00\x00\x00\x00\x00\x00\x00\x00\x02\x00\x3e\x00'';
      mask = ''\xff\xff\xff\xff\xff\xfe\xfe\x00\xff\xff\xff\xff\xff\xff\xff\xff\xfe\xff\xff\xff'';
    };
  };
  nix.settings.extra-platforms = [
    "x86_64-linux"
    "i686-linux"
  ];
  nixpkgs.overlays = [
    (final: prev: {
      virglrenderer = prev.virglrenderer.overrideAttrs (old: {
        src = prev.fetchzip {
          url = "https://gitlab.freedesktop.org/virgl/virglrenderer/-/archive/b997bc18fafdcb8e563b7b07b54412ea61e12082/virglrenderer-b997bc18fafdcb8e563b7b07b54412ea61e12082.tar.bz2";
          hash = "sha256-6o/A+rvbFVFrH6vKnXQzTAINwkn+OTIdo7dXSUFeCqY=";
        };
      });
    })
  ];

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
