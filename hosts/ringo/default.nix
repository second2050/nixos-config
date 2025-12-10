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
    graphics.package =
      assert pkgs.mesa.version == "25.3.1";
      (import (fetchTarball {
        url = "https://github.com/NixOS/nixpkgs/archive/c5ae371f1a6a7fd27823bc500d9390b38c05fa55.tar.gz";
        sha256 = "sha256-4PqRErxfe+2toFJFgcRKZ0UI9NSIOJa+7RXVtBhy4KE=";
      }) { localSystem = pkgs.stdenv.hostPlatform; }).mesa;
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

  # x86-64 support
  nix.settings.extra-platforms = [ "x86_64-linux" ];
  boot.binfmt.registrations."muvm" = {
    # interpreter = "${pkgs.muvm}/bin/muvm";
    interpreter = "${pkgs.writeTextFile {
      name = "muvm-wrapper2";
      executable = true;
      text = ''
        #!${lib.getExe pkgs.fish}
        set pwd (pwd)
        exec ${lib.getExe pkgs.muvm} -- ${lib.getExe pkgs.fish} -c "cd $pwd; exec $argv"
      '';
    }}";
    fixBinary = true;
    wrapInterpreterInShell = false;
    matchCredentials = false;
    magicOrExtension = ''\x7fELF\x02\x01\x01\x00\x00\x00\x00\x00\x00\x00\x00\x00\x02\x00\x3e\x00'';
    mask = ''\xff\xff\xff\xff\xff\xfe\xfe\x00\xff\xff\xff\xff\xff\xff\xff\xff\xfe\xff\xff\xff'';
  };

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
