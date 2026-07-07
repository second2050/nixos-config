{
  lib,
  pkgs,
  config,
  inputs,
  self,
  ...
}:
let
  inherit (lib)
    mkIf
    mkEnableOption
    mkDefault
    mkOption
    mkForce
    genAttrs
    filter
    ;
  cfg = config.karui.base;
  en_xx = pkgs.fetchzip {
    url = "https://xyne.dev/projects/locale-en_xx/src/locale-en_xx-2017.tar.xz";
    hash = "sha256-EgvEZ5RVNMlDyzIPIpfr8hBD6lGbljtXhE4IjzJDq9I=";
  };
  en_de = pkgs.fetchurl {
    url = "https://raw.githubusercontent.com/leander-j/en_DE/8b172dde948f16cd8ec5966661e2c5b96c7ca983/en_DE";
    hash = "sha256-I/u1I55tkQTv6SoF/1fSAysnhNnMlUX1QPPnJvoovvQ=";
  };
  system = pkgs.stdenv.hostPlatform.system;
  nixOSVersion = config.system.nixos.release;
  customCodeNames = {
    "26.11" = "Neptune";
    "27.05" = "Plutia";
    "27.11" = "Uzume";
  };
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
  options.system.nixos.codeName = mkOption {
    apply = _: customCodeNames.${nixOSVersion} or "Histoire";
  };
  config = mkIf (cfg.enable) {
    # enable lix by default
    karui.lix.enable = mkDefault true;

    # nix configuration
    nix = {
      settings = {
        experimental-features = mkDefault [
          "nix-command"
          "flakes"
          "cgroups"
        ];
        trusted-users = [ "@wheel" ];
      };
      # add my inputs to the system registry
      registry =
        genAttrs (filter (n: n != "self") (builtins.attrNames inputs)) (input: {
          exact = true;
          from = {
            id = input;
            type = "indirect";
          };
          to = {
            path = inputs.${input}.outPath;
            type = "path";
          };
        })
        // {
          karuipkgs = {
            exact = true;
            from = {
              id = "karuipkgs";
              type = "indirect";
            };
            to = {
              path = inputs.self.outPath;
              type = "path";
            };
          };
        };
    };
    nixpkgs.config.allowUnfree = mkDefault true;
    nixpkgs.config.permittedInsecurePackages = [
      "electron-39.8.10"
    ];
    nixpkgs.overlays = [
      (final: _prev: {
        # replace insecure pnpm version
        pnpm_10_29_2 = final.pnpm_10;
      })
    ];

    # boot configuration
    boot.initrd.systemd.enable = mkDefault true;

    # enable zram
    zramSwap.enable = mkDefault true;

    # enable usage of run0
    security.pam.services.systemd-run0 = mkDefault { };

    # networking
    networking.networkmanager = {
      enable = mkDefault true;
      plugins = with pkgs; [
        networkmanager-openvpn
        networkmanager-l2tp
        networkmanager-strongswan
      ];
    };
    services.resolved = mkDefault {
      enable = true;
      settings.Resolve = {
        Cache = "no-negative";
        DNSSEC = "true";
        DNSOverTLS = "opportunistic";
        DNS = [
          "2620:fe::fe#dns.quad9.net"
          "9.9.9.9#dns.quad9.net"
        ];
        FallbackDNS = [
          "2620:fe::9#dns.quad9.net"
          "149.112.112.112#dns.quad9.net"
        ];
      };
    };
    services.avahi = mkDefault {
      enable = true;
      nssmdns4 = true;
      publish.enable = true;
    };
    services.strongswan = {
      enable = true;
      secrets = [ "ipsec.d/ipsec.nm-l2tp.secrets" ];
    };
    security.pki.certificateFiles = [
      "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt"
      ./dn42.crt
    ];

    # time, date and i18n
    time.timeZone = mkDefault "Europe/Berlin";
    i18n = mkDefault {
      defaultLocale = "en_XX.UTF-8";
      extraLocaleSettings = {
        LC_CTYPE = "en_US.UTF-8";
        LC_NUMERIC = "en_XX.UTF-8";
        LC_TIME = "en_XX.UTF-8";
        LC_COLLATE = "en_DE.UTF-8";
        LC_MONETARY = "en_DE.UTF-8";
        LC_PAPER = "en_DE.UTF-8";
        LC_NAME = "en_DE.UTF-8";
        LC_ADDRESS = "en_DE.UTF-8";
        LC_TELEPHONE = "en_DE.UTF-8";
        LC_MEASUREMENT = "en_DE.UTF-8";
        LC_IDENTIFICATION = "en_DE.UTF-8";
      };
      extraLocales = [
        "de_DE.UTF-8/UTF-8"
        "ja_JP.UTF-8/UTF-8"
        "en_DE.UTF-8/UTF-8"
        "en_XX.UTF-8/UTF-8"
      ];
      glibcLocales =
        (pkgs.glibcLocales.override {
          allLocales = false;
          locales = config.i18n.supportedLocales;
        }).overrideAttrs
          (_: {
            postUnpack = ''
              cp ${en_de} $sourceRoot/localedata/locales/en_DE
              cp ${en_xx}/en_XX@POSIX $sourceRoot/localedata/locales/en_XX
              echo 'en_DE.UTF-8/UTF-8 \' >> $sourceRoot/localedata/SUPPORTED
              echo 'en_XX.UTF-8/UTF-8 \' >> $sourceRoot/localedata/SUPPORTED
              cat $sourceRoot/localedata/SUPPORTED
            '';
          });
    };
    console = mkDefault {
      keyMap = "uk";
      useXkbConfig = false;
    };

    # remote access services
    services.openssh.enable = mkDefault true;
    programs.mosh = mkDefault {
      enable = true;
      withUtempter = true;
    };

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
    programs.command-not-found.enable = true;

    # Define a user account. Don't forget to set a password with ‘passwd’.
    users.users.${cfg.user.username} = {
      description = cfg.user.fullname;
      isNormalUser = true;
      extraGroups = [
        "wheel" # Enable ‘sudo’ for the user.
        "networkmanager"
        "scanner"
        "lp"
        "libvirtd"
      ];
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFlAc7SsDm9n72StyPmm6CJsLFCd14SOb/cXDoLxiKRN 0001 second2050@vault"
      ];
      shell = pkgs.fish;
    };

    # home-manager
    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      sharedModules = [ inputs.plasma-manager.homeModules.plasma-manager ];
      users.${cfg.user.username} = import "${self}/homeModules/base";
      extraSpecialArgs = {
        inherit inputs self;
        userName = cfg.user.username;
        userHome = config.users.users.${cfg.user.username}.home;
      };
    };

    # misc. config
    environment = {
      systemPackages = [ pkgs.p11-kit ];
      shellAliases = mkForce { }; # disable default shell aliases
    };
    services.getty.greetingLine = "[1;96mNixOS ${config.system.nixos.release}[0m on \\m [\\l]"; # first line on getty login
    programs.command-not-found.dbPath =
      mkForce
        inputs.flake-programs-sqlite.packages.${system}.programs-sqlite;
  };
}
