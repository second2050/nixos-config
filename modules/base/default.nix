{
  lib,
  pkgs,
  config,
  ...
}:
let
  inherit (lib)
    mkIf
    mkEnableOption
    mkDefault
    mkOption
    mkForce
    ;
  cfg = config.karui.base;
in
{
  options.karui.base = {
    enable = mkEnableOption "karui’s base configuration";
    user.username = mkOption {
      default = "karui";
      description = "Username for the main user.";
    };
    user.fullname = mkOption {
      default = "${cfg.user.username} (>‿◕)~♥";
      description = "Display name for the main user.";
    };
  };
  options.system.nixos.codeName = mkOption { apply = _: "Cuddly Cuties"; };
  config = mkIf (cfg.enable) {
    # nix configuration
    nix.settings.experimental-features = mkDefault [
      "nix-command"
      "flakes"
      "repl-flake"
    ];
    nixpkgs.config.allowUnfree = mkDefault true;

    # boot configuration
    boot.initrd.systemd.enable = mkDefault true;

    # enable zram
    zramSwap.enable = mkDefault true;

    # enable usage of run0
    security.pam.services.systemd-run0 = mkDefault { };

    # networking
    networking.networkmanager.enable = mkDefault true;
    services.resolved = mkDefault {
      enable = true;
      dnssec = "true";
      dnsovertls = "opportunistic";
      fallbackDns = [
        "1.0.0.1#one.one.one.one"
        "2606:4700:4700::1111#one.one.one.one"
        "2606:4700:4700::1001#one.one.one.one"
      ];
      extraConfig = "DNS=1.1.1.1#one.one.one.one";
    };
    services.avahi = mkDefault {
      enable = true;
      nssmdns4 = true;
      publish.enable = true;
    };

    # time, date and i18n
    time.timeZone = mkDefault "Europe/Berlin";
    i18n = mkDefault {
      defaultLocale = "en_US.UTF-8";
      supportedLocales = [
        "en_US.UTF-8/UTF-8"
        "de_DE.UTF-8/UTF-8"
        "ja_JP.UTF-8/UTF-8"
      ];
    };
    console = mkDefault {
      keyMap = "uk";
      useXkbConfig = false;
    };

    # system services
    services.openssh.enable = mkDefault true;

    # system applications
    programs.fish.enable = mkDefault true;
    programs.neovim = mkDefault {
      enable = true;
      defaultEditor = true;
      vimAlias = true;
      viAlias = true;
    };
    programs.git.enable = mkDefault true;
    programs.nh = mkDefault {
      enable = true;
      flake = "/etc/nixos";
    };

    # Define a user account. Don't forget to set a password with ‘passwd’.
    users.users.${cfg.user.username} = {
      description = cfg.user.fullname;
      isNormalUser = true;
      extraGroups = [
        "wheel" # Enable ‘sudo’ for the user.
        "networkmanager"
      ];
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFlAc7SsDm9n72StyPmm6CJsLFCd14SOb/cXDoLxiKRN 0001 second2050@vault"
      ];
      shell = pkgs.fish;
    };

    # misc. config
    environment.shellAliases = mkForce { }; # disable default shell aliases
    services.getty.greetingLine = "[1;96mNixOS ${config.system.nixos.release}[0m on \\m [\\l]"; # first line on getty login
  };
}
