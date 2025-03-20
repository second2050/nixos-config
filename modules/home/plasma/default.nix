{
  config,
  pkgs,
  ...
}:
{
  imports = [
    ./plasma.nix
    ./konsole.nix
  ];
}
