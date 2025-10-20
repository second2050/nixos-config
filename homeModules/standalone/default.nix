{
  flakeDir,
  inputs,
  pkgs,
  lib,
  ...
}:
{
  home.packages = [ pkgs.fish ];
  programs.nh = {
    enable = true;
    homeFlake = flakeDir;
  };
  nix.registry = lib.genAttrs (lib.filter (n: n != "self") (builtins.attrNames inputs)) (input: {
    exact = true;
    from = {
      id = input;
      type = "indirect";
    };
    to = {
      path = inputs.${input}.outPath;
      type = "path";
    };
  });
}
