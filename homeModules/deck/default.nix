{ pkgs, inputs, ... }:
{
  home.packages = with pkgs; [
    r2modman
    sm64archipelago
  ];
}
