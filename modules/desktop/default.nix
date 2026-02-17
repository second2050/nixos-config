{
  config,
  inputs,
  lib,
  pkgs,
  self,
  ...
}:
let
  inherit (lib) mkIf mkEnableOption mkOption;
  cfg = config.karui.desktop;
  system = pkgs.stdenv.hostPlatform.system;
  assets = self.assets.${system};
in
{
  options.karui.desktop = {
    enable = mkEnableOption "karui’s desktop configuration";
    autoLogin = mkEnableOption "enable autologin for encrypted systems";
    wallpaper = mkOption {
      default = assets.currentWallpaper;
      description = "wallpaper for this configuration";
    };
  };
  config = mkIf (cfg.enable) {
    # KDE
    programs.xwayland.enable = true;
    services.displayManager = {
      autoLogin.user = mkIf cfg.autoLogin config.karui.base.user.username;
      sddm = {
        enable = true;
        wayland.enable = true;
      };
    };
    services.desktopManager.plasma6.enable = true;

    # KDE Home-Manager configuration
    home-manager.users.${config.karui.base.user.username}.imports = [
      "${self}/homeModules/plasma"
      "${self}/homeModules/desktop"
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
        waylandFrontend = true;
        addons =
          with pkgs;
          with kdePackages;
          [
            fcitx5-qt
            fcitx5-mozc-ut
            fcitx5-gtk
          ];
      };
    };

    # Fonts
    fonts = {
      enableDefaultPackages = true;
      packages = with pkgs; [
        noto-fonts
        noto-fonts-cjk-sans
        noto-fonts-cjk-serif
        noto-fonts-color-emoji
        cascadia-code
        delugia-code
        comfortaa
        maple-mono.NF-unhinted
        maple-mono.NF-CN-unhinted
        kosugi-maru
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
    environment.plasma6.excludePackages =
      with pkgs;
      with kdePackages;
      [
        gwenview
      ];

    # Extra Packages
    programs.kdeconnect.enable = true;
    programs.kde-pim = {
      enable = true;
      merkuro = true;
      kmail = true;
    };
    environment.systemPackages =
      with pkgs;
      with kdePackages;
      [
        # KDE Applications
        haruna # Video Player
        karp # KDE PDF Arranger
        kleopatra # GnuPG Frontend
        koko # Photos
        krdc # RDP/VNC client
        krfb # VNC screen sharing
        partitionmanager
        quasselClient # IRC
        yakuake # Drop-Down Terminal

        # Applets
        applet-window-buttons6
        applet-window-title6
        kdecoration

        # Themes
        inputs.darkly-qt.packages.${system}.darkly-qt5
        inputs.darkly-qt.packages.${system}.darkly-qt6

        # KWin Effects + Scripts
        inputs.kwin-effects-forceblur.packages.${system}.default
        kde-rounded-corners
        kwin-effects-geometry-change
        kwin-scripts-temporary-virtual-desktops

        # Spellchecker
        hunspell
        hunspellDicts.de_DE
        hunspellDicts.en_GB-large
        hunspellDicts.en_US-large

        # Misc. Applications
        contour # Alternative Terminal
        libreoffice-qt
        syncthing
        syncthingtray
        xorg.xauth
        (pkgs.writeTextDir "share/sddm/themes/breeze/theme.conf.user" ''
          [General]
          background = "${assets.currentWallpaper}"
        '')
      ];
    services.flatpak.enable = true;

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

    # Zen use CA store
    environment.etc = {
      "zen/policies/policies.json".text = builtins.toJSON {
        policies.SecurityDevices.Add.p11-kit-trust = "${pkgs.p11-kit}/lib/pkcs11/p11-kit-trust.so";
      };
    };

    # SSH options
    programs.ssh.setXAuthLocation = true;

    # Hardware
    powerManagement.enable = true;
    karui.hardware.pen-input = true;

    # kmscon
    services.kmscon.enable = true;
  };
}
