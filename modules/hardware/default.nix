{
  config,
  lib,
  pkgs,
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
    # extra rules; due to uaccess tagging being ignored after 73-seat-late.rules
    #              i just create my own udev rules package with the correct ordering.
    #              see https://github.com/NixOS/nixpkgs/issues/308681#issuecomment-2092380710
    #              and https://github.com/systemd/systemd/issues/4288#issuecomment-348166161
    services.udev.packages = mkIf (cfg.extra) (
      lib.singleton (
        pkgs.writeTextFile {
          name = "karui-extra-rules";
          text = ''
            # led name badge
            SUBSYSTEM=="usb",  ATTRS{idVendor}=="0416", ATTRS{idProduct}=="5020", MODE="0666"
            KERNEL=="hidraw*", ATTRS{idVendor}=="0416", ATTRS{idProduct}=="5020", ATTRS{busnum}=="1", MODE="0666"
            # usbkvm / pro
            KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{product}=="USBKVM", TAG+="uaccess", 
          '';
          destination = "/etc/udev/rules.d/70-karui.rules";
        }
      )
    );
  };
}
