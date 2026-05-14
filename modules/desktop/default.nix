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
        includeUserConf = false;
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
        cantata # Music Player/MPD Client
        (haruna.override { yt-dlp = (yt-dlp.override { deno = nodejs; }); }) # Video Player
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
        cobalt-icon-theme
        eleven-icon-theme
        inputs.darkly-qt.packages.${system}.darkly-qt5
        inputs.darkly-qt.packages.${system}.darkly-qt6

        # KWin Effects + Scripts
        inputs.kwin-effects-forceblur.packages.${system}.default
        (kde-rounded-corners.overrideAttrs (oldAttrs: {
          version = "0.8.6-2cf9329";
          src = fetchFromGitHub {
            owner = "matinlotfali";
            repo = "KDE-Rounded-Corners";
            rev = "2cf9329b31b3152e5513f7069c4bb11c765fdc6e";
            hash = "sha256-mVoLCnpWHC2qDouO97n2cmxiewLCokjnWl1I9tnkIN4=";
          };
        }))
        kwin-effects-geometry-change
        kwin-scripts-temporary-virtual-desktops

        # Spellchecker
        enchant
        hunspell
        hunspellDicts.de_DE
        hunspellDicts.en_GB-large
        hunspellDicts.en_US-large

        # Misc. Applications
        (contour.overrideAttrs (prev: {
          version = "0.6.3.8249";
          src = pkgs.fetchFromGitHub {
            owner = "contour-terminal";
            repo = "contour";
            rev = "v0.6.3.8249";
            hash = "sha256-+rr1bn4O5v9rXyoIx+ejL+qe5Kf2bFpgWA3DkWRcDYk=";
          };

          cmakeFlags = [ "-DCONTOUR_USE_CPM=OFF" ];

          buildInputs = builtins.filter (pkg: pkg.pname != "libunicode") prev.buildInputs ++ [
            (pkgs.libunicode.overrideAttrs {
              version = "0.9.0";

              src = pkgs.fetchFromGitHub {
                owner = "contour-terminal";
                repo = "libunicode";
                rev = "v0.9.0";
                hash = "sha256-EBu8zn5XritudZmBvQmjOmU08XLjhyKI6hVCrnWoR6k=";
              };

              patches = [ ];

              cmakeFlags = [
                "-DLIBUNICODE_UCD_DIR=${
                  pkgs.fetchzip {
                    url = "https://www.unicode.org/Public/17.0.0/ucd/UCD.zip";
                    hash = "sha256-k2OFy8xPvn+Bboyr1EsmZNeVDOglvk2kSZ+H17YaX60=";
                    stripRoot = false;
                  }
                }"
              ];
            })
          ];
        }))
        libreoffice-qt
        syncthing
        syncthingtray
        xauth
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
