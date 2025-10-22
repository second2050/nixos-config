{
  flakeDir,
  inputs,
  pkgs,
  lib,
  ...
}:
let
  inherit (lib)
    genAttrs
    filter
    ;
in
{
  home.packages = [ pkgs.fish ];
  programs.nh = {
    enable = true;
    homeFlake = flakeDir;
  };
  nix.registry =
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
}
