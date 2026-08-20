{
  lib,
  pkgs,
  config,
  ...
}:
let
  inherit (lib)
    mkEnableOption
    mkIf
    ;
  cfg = config.karui.vmHost;
in
{
  options.karui.vmHost.enable = mkEnableOption "karui’s virtual machine host configuration";
  config = mkIf (cfg.enable) {
    virtualisation.libvirtd = {
      enable = true;
      onBoot = "ignore";
      sshProxy = true;
      nss.enableGuest = true;
      qemu = {
        runAsRoot = false;
        swtpm.enable = true;
      };
    };
    environment.systemPackages =
      with pkgs;
      mkIf config.karui.desktop.enable [
        virt-manager
      ];
  };
}
