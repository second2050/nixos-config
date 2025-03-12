# Karui’s KDE Desktop Config
{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:{
  # KDE
  services.xserver.enable = true;
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
  };
  services.desktopManager.plasma6.enable = true;

  # Sound Server
  services.pipewire = {
    enable = true;
    pulse.enable = true;
  };

  # Input Method Editor
  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5 = {
      plasma6Support = true;
      waylandFrontend = true;
      addons = with pkgs; [
        fcitx5-mozc-ut
        fcitx5-gtk
      ];
    };
  };

  # Fonts
  fonts = {
    enableDefaultPackages = true;
    packages = [
      pkgs.cascadia-code
    ];
  };

  # Extra Packages
  environment.systemPackages = with pkgs; [
    kdePackages.yakuake
    kdePackages.applet-window-buttons6
    kdePackages.kdecoration
  ];
}

