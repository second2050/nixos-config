{ pkgs, ... }:
{
  home.packages = with pkgs; [
    kemai
  ];
}
