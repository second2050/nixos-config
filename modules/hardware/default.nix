{
  lib,
  config,
  ...
}:
let
  inherit (lib) mkIf mkEnableOption;
  cfg = config.karui.hardware;
in
{
  options.karui.hardware = {
    razer = mkEnableOption "razer hardware configuration";
    pen-input = mkEnableOption "graphic tablet configuration";
    extra = mkEnableOption "extra udev rules and packages";
  };
  config = {
    # razer
    hardware.openrazer = mkIf (cfg.razer) {
      enable = true;
      users = [ "${config.karui.base.user.username}" ];
      keyStatistics = true;
    };
    # pen-input
    hardware.opentabletdriver = mkIf (cfg.pen-input) {
      enable = true;
      daemon.enable = true;
    };
    services.udev.extraRules = mkIf (cfg.extra) ''
      # led name badge
      SUBSYSTEM=="usb",  ATTRS{idVendor}=="0416", ATTRS{idProduct}=="5020", MODE="0666"
      KERNEL=="hidraw*", ATTRS{idVendor}=="0416", ATTRS{idProduct}=="5020", ATTRS{busnum}=="1", MODE="0666"
      # usbkvm / pro
      KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{product}=="USBKVM", TAG+="uaccess"
    '';
  };
}
