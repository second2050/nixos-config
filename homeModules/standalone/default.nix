{ pkgs, flakeDir, ... }:
{
  home.packages = [ pkgs.fish ];
  programs.nh = {
    enable = true;
    homeFlake = flakeDir;
  };
}
