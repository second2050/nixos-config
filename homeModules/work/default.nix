{ pkgs, ... }:
{
  home.packages = with pkgs; [
    doggo
    kemai
    mtr
  ];
}
