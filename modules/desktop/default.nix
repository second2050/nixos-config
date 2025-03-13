{
  lib,
  pkgs,
  config,
  inputs,
  system,
  ...
}:
let
  inherit (lib) mkIf mkEnableOption;
  cfg = config.karui.desktop;
  # delugia-code = pkgs.stdenvNoCC.mkDerivation rec {
  #   name = "delugia-code";
  #   version = "2404.23";
  #   src = pkgs.fetchzip {
  #     url = "https://github.com/adam7/delugia-code/releases/download/v${version}/delugia-complete.zip";
  #     stripRoot = false;
  #     hash = "sha256-2jIHkkAUDtW0CVwakEzZGHgbMByh/00F5jlZ55RGIag=";
  #   };
  #
  #   installPhase = ''
  #     runHook preInstall
  #     install -Dm644 delugia-complete/*.ttf -t $out/share/fonts/truetype
  #     runHook postInstall
  #   '';
  #
  #   meta = with lib; {
  #     description = "Monospaced font that includes programming ligatures and is designed to enhance the modern look and feel of the Windows Terminal";
  #     homepage = "https://github.com/adam7/delugia-code";
  #     # license = licenses.ofl;
  #     # platforms = platforms.all;
  #   };
  # };
  applet-window-title6 = pkgs.stdenv.mkDerivation rec {
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
    '';
    meta = with lib; {
      description = "Plasma 6 applet that shows the application title and icon for active window";
      homepage = "https://github.com/dhruv8sh/plasma6-window-title-applet";
    };
  };
in {
  options.karui.desktop = {
    enable = mkEnableOption "karui’s desktop configuration";
  };
  config = mkIf (cfg.enable) {
    # KDE
    services.xserver.enable = true;
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
      ];
      fontconfig = {
        enable = true;
        defaultFonts = {
          serif = [ "Noto Serif" ];
          sansSerif = [ "Noto Sans" ];
          monospace = [ "Delugia" ];
          emoji = [ "Noto Color Emoji" ];
        };
      };
    };

    # Extra Packages
    environment.systemPackages = with pkgs; [
      kdePackages.yakuake
      kdePackages.applet-window-buttons6
      kdePackages.kdecoration
      applet-window-title6
      inputs.darkly-qt.packages.${pkgs.system}.darkly-qt5
      inputs.darkly-qt.packages.${pkgs.system}.darkly-qt6
    ];

    # Fancy Boot
    boot.plymouth = {
      enable = true;
    };
    boot = {
      kernelParams = [
        "quiet"
      ];
      # loader.timeout = 0;
    };
  };
}
