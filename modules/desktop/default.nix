{
  lib,
  pkgs,
  config,
  inputs,
  ...
}:
let
  inherit (lib) mkIf mkEnableOption;
  cfg = config.karui.desktop;
  applet-window-title6 = pkgs.stdenvNoCC.mkDerivation rec {
    name = "applet-window-title6";
    version = "0.9.0";
    src = pkgs.fetchzip {
      url = "https://github.com/dhruv8sh/plasma6-window-title-applet/archive/refs/tags/v${version}.tar.gz";
      stripRoot = false;
      hash = "sha256-YUnIKX5VlgC8vUdGwYPkzupIUxudAsBcf5tpK0tt0n8=";
    };
    installPhase = ''
      runHook preInstall
      mkdir -p "$out/share/plasma/plasmoids/org.kde.windowtitle"
      cp -r plasma6-window-title-applet-${version}/* "$out/share/plasma/plasmoids/org.kde.windowtitle"
      rm "$out/share/plasma/plasmoids/org.kde.windowtitle/README.md"
      runHook postInstall
    '';
    meta = {
      description = "Plasma 6 applet that shows the application title and icon for active window";
      homepage = "https://github.com/dhruv8sh/plasma6-window-title-applet";
    };
  };
  kwin-effects-geometry-change = pkgs.stdenvNoCC.mkDerivation rec {
    name = "kwin-effects-geometry-change";
    version = "1.4";
    src = pkgs.fetchzip {
      url = "https://github.com/peterfajdiga/kwin4_effect_geometry_change/releases/download/v${version}/kwin4_effect_geometry_change_1_4.tar.gz";
      stripRoot = false;
      hash = "sha256-wPgB1ojLNNAnWA7916qBq12VdhEbwvRA1fwb27tZYQk=";
    };
    installPhase = ''
      runHook preInstall
      mkdir -p "$out/share/kwin/effects/kwin4_effect_geometry_change"
      cp -r package/* "$out/share/kwin/effects/kwin4_effect_geometry_change"
      runHook postInstall
    '';
  };
  kwin-scripts-temporary-virtual-desktops = pkgs.stdenvNoCC.mkDerivation rec {
    name = "";
    version = "0.4.0";
    src = pkgs.fetchgit {
      url = "https://github.com/Ubiquitine/temporary-virtual-desktops.git";
      rev = "refs/tags/v${version}";
      hash = "sha256-PU3/FRa38/4bFMNSc7uhSYlHPqaZ9HMbjnTU9Z6O2JI=";
    };
    installPhase = ''
      runHook preInstall
      mkdir -p "$out/share/kwin/scripts/temporary-virtual-desktops"
      cp -r * "$out/share/kwin/scripts/temporary-virtual-desktops"
      runHook postInstall
    '';
  };
  kosugi-maru = pkgs.stdenvNoCC.mkDerivation {
    name = "kosugi-maru";
    version = "4.001";
    src = pkgs.fetchgit {
      url = "https://github.com/googlefonts/kosugi-maru.git";
      rev = "bd22c671a9ffc10cc4313e6f2fd75f2b86d6b14b";
      hash = "sha256-gMilWV4t/yB3TtMe30IXHUlmSJDkD2THYUfbt3eT+h0=";
    };
    installPhase = ''
      runHook preInstall
      mkdir -p $out/share/X11/fonts
      cp -r fonts/ttf/*.ttf $out/share/X11/fonts/
      cp -r fonts/otf/*.otf $out/share/X11/fonts/
      runHook postInstall
    '';
  };
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
        kosugi-maru
      ];
      fontconfig = {
        enable = true;
        defaultFonts = {
          serif = [ "Noto Serif" ];
          sansSerif = [ "Noto Sans" ];
          monospace = [ "Maple Mono NF" ];
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
          </fontconfig>
        '';
      };
    };

    # Extra Services
    services.power-profiles-daemon.enable = true;

    # Exclude Default Packages
    environment.plasma6.excludePackages = with pkgs; [
      kdePackages.gwenview
    ];

    # Extra Packages
    programs.kde-pim = {
      enable = true;
      merkuro = true;
    };
    environment.systemPackages = [
      # KDE Applications
      pkgs.kdePackages.yakuake # Drop-Down Terminal
      pkgs.kdePackages.koko # Photos
      pkgs.kdePackages.calligra # Office Suite
      pkgs.kdePackages.neochat # Matrix
      pkgs.quasselClient # IRC

      # Applets
      pkgs.kdePackages.applet-window-buttons6
      pkgs.kdePackages.kdecoration
      applet-window-title6

      # Themes
      inputs.darkly-qt.packages.${pkgs.system}.darkly-qt5
      inputs.darkly-qt.packages.${pkgs.system}.darkly-qt6

      # KWin Effects + Scripts
      inputs.kwin-effects-forceblur.packages.${pkgs.system}.default
      kwin-effects-geometry-change
      kwin-scripts-temporary-virtual-desktops
      pkgs.kde-rounded-corners

      # Misc. Applications
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

    karui.hardware.pen-input = true;
  };
}
