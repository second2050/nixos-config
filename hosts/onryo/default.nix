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
    cores = 8;
    memory = "12GiB";
    onDemand = true;
  };
  system.stateVersion = 7;
}
