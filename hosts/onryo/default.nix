{
  config,
  lib,
  pkgs,
  self,
  inputs,
  ...
}:

{
  nixpkgs.hostPlatform = {
    system = "aarch64-darwin";
  };
  karui.base.enable = true;
  nix-rosetta-builder = {
    onDemand = true;
  };
  system.stateVersion = 7;
}
