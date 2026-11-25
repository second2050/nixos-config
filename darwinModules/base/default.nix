{
  lib,
  pkgs,
  config,
  inputs,
  self,
  ...
}:
let
  inherit (lib)
    mkIf
    mkEnableOption
    mkDefault
    mkOption
    mkForce
    genAttrs
    filter
    ;
  cfg = config.karui.base;
in
{
  options.karui.base = {
    enable = mkEnableOption "karui’s base configuration";
  };
  config = mkIf (cfg.enable) {
    # enable lix by default
    karui.lix.enable = mkDefault true;

    # nix configuration
    nix = {
      settings = {
        experimental-features = mkDefault [
          "nix-command"
          "flakes"
        ];
        trusted-users = [ "@admin" ];
        substituters = [
          "https://attic.karui.moe/karui"
        ];
        trusted-public-keys = [
          "karui:8uidONyUZQeIiM7V0zmDXnSvMCLyZmwHvfJfAgFEbYc="
        ];
      };
      # add my inputs to the system registry
      registry =
        genAttrs (filter (n: n != "self") (builtins.attrNames inputs)) (input: {
          exact = true;
          from = {
            id = input;
            type = "indirect";
          };
          to = {
            path = inputs.${input}.outPath;
            type = "path";
          };
        })
        // {
          karuipkgs = {
            exact = true;
            from = {
              id = "karuipkgs";
              type = "indirect";
            };
            to = {
              path = inputs.self.outPath;
              type = "path";
            };
          };
        };
    };
    nixpkgs = import "${self}/modules/base/nixpkgs.nix";

    # system applications
    programs.fish.enable = mkDefault true;

    # home-manager
    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      sharedModules = [ ];
    };

    # misc. config
    environment = {
      shells = [
        pkgs.fish
      ];
      systemPackages = with pkgs; [
      ];
      shellAliases = mkForce { }; # disable default shell aliases
    };
  };
}
