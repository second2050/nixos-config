{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.boot.loader.refind-stanza;
  efi = config.boot.loader.efi;
  refindStanzaBuilder = pkgs.replaceVarsWith {
    src = ./refind_stanza_builder.py;
    isExecutable = true;
    replacements = {
      inherit (efi) efiSysMountPoint;
      inherit (pkgs) python3;

      nix = config.nix.package.out;
      nix_subvolume = cfg.subvolume;
      volume = cfg.volume;
    };
  };
in
{
  options.boot.loader.refind-stanza = {
    enable = mkEnableOption "Enable Refind stanza generation";
    volume = mkOption {
      default = "nixos";
      description = "Name of the btrfs volume";
    };
    subvolume = mkOption {
      default = "@nix";
      description = "Subvolume path to the nix store";
    };
  };
  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      findutils
      gptfdisk
      refind
    ];
    assertions = [
      {
        assertion = (config.boot.kernelPackages.kernel.features or { efiBootStub = true; }) ? efiBootStub;
        message = "This kernel does not include an EFI Boot Stub";
      }
    ];
    boot.loader.grub.enable = mkDefault false;
    system = {
      build.installBootLoader = refindStanzaBuilder;
      boot.loader.id = "refind-stanza";
      requiredKernelConfig = with config.lib.kernelConfig; [
        (isYes "EFI_STUB")
      ];
    };
  };
}
