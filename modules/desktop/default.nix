{
  lib,
  pkgs,
  config,
  inputs,
  self,
  ...
}:
let
  inherit (lib) mkIf mkEnableOption;
  cfg = config.karui.desktop;
in
{
  options.karui.desktop = {
    enable = mkEnableOption "karui’s desktop configuration";
  };
  config = mkIf (cfg.enable) {
    # KDE
    programs.xwayland.enable = true;
    services.displayManager = {
      autoLogin.user = "karui";
      sddm = {
        enable = true;
        wayland.enable = true;
      };
    };
    services.desktopManager.plasma6.enable = true;

    # KDE Home-Manager configuration
    home-manager.users.${config.karui.base.user.username}.imports = [
      "${self}/modules/home/plasma"
      "${self}/modules/home/desktop"
    ];

    # Sound Server
    services.pipewire = {
      enable = true;
      pulse.enable = true;
    };

    # Input Method Editor
    services.xserver = {
      xkb.layout = "gb";
    };
    i18n.inputMethod = {
      enable = true;
      type = "fcitx5";
      fcitx5 = {
        plasma6Support = true;
        waylandFrontend = true;
        addons = with pkgs; [
          kdePackages.fcitx5-qt
          fcitx5-mozc-ut
          fcitx5-gtk
        ];
      };
    };

    # Fonts
    fonts = {
      enableDefaultPackages = true;
      packages = [
        pkgs.noto-fonts
        pkgs.noto-fonts-cjk-sans
        pkgs.noto-fonts-cjk-serif
        pkgs.noto-fonts-color-emoji
        pkgs.cascadia-code
        pkgs.delugia-code
        pkgs.comfortaa
        pkgs.maple-mono.NF-unhinted
        pkgs.maple-mono.NF-CN-unhinted
        pkgs.kosugi-maru
      ];
      fontconfig = {
        enable = true;
        defaultFonts = {
          serif = [ "Noto Serif" ];
          sansSerif = [ "Noto Sans" ];
          monospace = [ "Maple Mono NF CN" ];
          emoji = [ "Noto Color Emoji" ];
        };
        localConf = ''
          <?xml version="1.0"?>
          <!DOCTYPE fontconfig SYSTEM "urn:fontconfig:fonts.dtd">
          <fontconfig>
            <!-- enable stylistic sets for maple-mono -->
            <match target="font">
              <test name="family" compare="eq" ignore-blanks="true">
                <string>Maple Mono NF</string>
              </test>
              <edit name="fontfeatures" mode="append">
                <string>calt on</string>
              </edit>
            </match>
            <match target="font">
              <test name="family" compare="eq" ignore-blanks="true">
                <string>Maple Mono NF CN</string>
              </test>
              <edit name="fontfeatures" mode="append">
                <string>calt on</string>
              </edit>
            </match>
          </fontconfig>
        '';
      };
    };

    # Extra Services
    services.power-profiles-daemon.enable = true;
    hardware.sane.enable = true;
    hardware.sane.netConf = "192.168.2.8";
    services.printing.enable = true;

    # Exclude Default Packages
    environment.plasma6.excludePackages = with pkgs; [
      kdePackages.gwenview
    ];

    # Extra Packages
    programs.kdeconnect.enable = true;
    programs.kde-pim = {
      enable = true;
      merkuro = true;
      kmail = true;
    };
    environment.systemPackages = [
      # KDE Applications
      pkgs.kdePackages.yakuake # Drop-Down Terminal
      pkgs.kdePackages.koko # Photos
      pkgs.kdePackages.calligra # Office Suite
      pkgs.kdePackages.neochat # Matrix
      pkgs.kdePackages.partitionmanager
      pkgs.haruna # Video Player
      pkgs.quasselClient # IRC

      # Applets
      pkgs.kdePackages.applet-window-buttons6
      pkgs.kdePackages.kdecoration
      pkgs.applet-window-title6

      # Themes
      inputs.darkly-qt.packages.${pkgs.system}.darkly-qt5
      inputs.darkly-qt.packages.${pkgs.system}.darkly-qt6

      # KWin Effects + Scripts
      inputs.kwin-effects-forceblur.packages.${pkgs.system}.default
      pkgs.kwin-effects-geometry-change
      pkgs.kwin-scripts-temporary-virtual-desktops
      pkgs.kde-rounded-corners

      # Spellchecker
      pkgs.hunspell
      pkgs.hunspellDicts.de_DE
      pkgs.hunspellDicts.en_GB-large
      pkgs.hunspellDicts.en_US-large

      # Misc. Applications
      pkgs.contour # Alternative Terminal
      pkgs.syncthing
      pkgs.syncthingtray
    ];
    services.flatpak.enable = true;
    nixpkgs.config.permittedInsecurePackages = [
      "olm-3.2.16" # dependency of neochat
    ];

    # Fancy Boot
    boot.plymouth = {
      enable = true;
      theme = "breeze";
      themePackages = [
        (pkgs.kdePackages.breeze-plymouth.override {
          logoFile = pkgs.fetchurl {
            url = "https://i.second2050.me/miku_bordered@5x.png";
            hash = "sha256-+om4V0ctmy/qb+cGElCxw9RBoDjygVOIcoMSoKLZZnU=";
          };
          logoName = "nixos";
          osName = "MikuOS for Workgroups"; # using NBSP (0x00a0) instead of regular spaces (0x0020)
          osVersion = config.system.nixos.release;
        })
      ];
    };
    boot = {
      kernelParams = [
        "quiet"
      ];
      # loader.timeout = 0;
    };

    # OoM Killer, KDE already starts apps in their own CGroup
    # so we can just use systemd-oomd and fedora-like defaults.
    systemd.oomd = {
      enable = true;
      enableSystemSlice = true;
      enableUserSlices = true;
    };

    # Firefox use CA store
    environment.etc = {
      "zen/policies/policies.json".text = builtins.toJSON {
        policies.SecurityDevices.Add.p11-kit-trust = "${pkgs.p11-kit}/lib/pkcs11/p11-kit-trust.so";
      };
    };

    # Hardware
    powerManagement.enable = true;
    karui.hardware.pen-input = true;
  };
}
