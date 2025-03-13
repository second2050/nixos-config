# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, inputs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = false;
  boot.kernelParams = [
    "apple_dcp.show_notch=1"
  ];
  boot.initrd.systemd.enable = true;
  boot.extraModprobeConfig = ''
    options hid_apple fnmode=2
  '';

  # hardware stuff
  hardware = {
    asahi = {
      peripheralFirmwareDirectory = inputs.apple-silicon-firmware;
      withRust = true;
      useExperimentalGPUDriver = true;
      # experimentalGPUInstallMode = "replace";
    };
    graphics.enable = true;
  };

  # enable desktop
  karui.desktop.enable = true;

  networking.hostName = "ringo";
  networking.hostId = "a0fb3fd3";
  networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.

  # Set your time zone.
  time.timeZone = "Europe/Berlin";

  # Select internationalisation properties.
  i18n = {
    defaultLocale = "en_US.UTF-8";
    # supportedLocales = [
    #   "de_DE.UTF-8/UTF-8"
    #   "en_DK.UTF-8/UTF-8"
    #   "ja_JP.UTF-8/UTF-8"
    # ];
    # extraLocaleSettings = {
    #   LANGUAGE = "en_US.UTF-8";
    #   LC_ADDRESS = "en_US.UTF-8";
    #   LC_COLLATE = "en_US.UTF-8";
    #   LC_CTYPE = "en_US.UTF-8";
    #   LC_IDENTIFICATION = "en_US.UTF-8";
    #   LC_MEASUREMENT = "en_US.UTF-8";
    #   LC_MESSAGES = "en_US.UTF-8";
    #   LC_MONETARY = "en_US.UTF-8";
    #   LC_NAME = "en_US.UTF-8";
    #   LC_NUMERIC = "en_US.UTF-8";
    #   LC_PAPER = "en_US.UTF-8";
    #   LC_TELEPHONE = "en_US.UTF-8";
    #   LC_TIME = "en_DK.UTF-8";
    # };
  };
  console = {
    # font = "Lat2-Terminus32";
    keyMap = "uk";
    useXkbConfig = false; # use xkb.options in tty.
  };
  # services.kmscon = {
  #   enable = true;
  #   extraConfig = ''
  #     xkb-layout=gb
  #   '';
  #   fonts = [
  #     {
  #       name = "Delugia";
  #       package = pkgs.delugia-code;
  #     }
  #   ];
  # };

  nix = {
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
    };
  };

  # Allow Unfree
  nixpkgs.config.allowUnfree = true;
  # nixpkgs.overlays = [ inputs.karuipkgs ];

  # Configure keymap in X11
  # services.xserver.xkb.layout = "us";
  # services.xserver.xkb.options = "eurosign:e,caps:escape";

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable touchpad support (enabled default in most desktopManager).
  # services.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.karui = {
    isNormalUser = true;
    extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
    packages = with pkgs; [
      
    ];
    shell = pkgs.fish;
  };

  # Shell config
  programs.fish.enable = true;
  environment.shellAliases = lib.mkForce {}; # disable default shell aliases

  # Applications
  # programs.firefox.enable = true;
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    vimAlias = true;
    viAlias = true;
  };
  programs.git.enable = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  # environment.systemPackages = with pkgs; [
  #   vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
  #   wget
  # ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "25.05"; # Did you read the comment?

}

