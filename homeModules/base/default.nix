{
  pkgs,
  userName,
  userHome,
  ...
}:
let
  inherit (pkgs.stdenv.hostPlatform) isLinux;
in
{
  # User informations for Home Manager
  home.username = userName;
  home.homeDirectory = userHome;

  # Packages
  home.packages = with pkgs; [
    bat
    btop
    difftastic
    git
    jq
    lsd
    mommy
    ncdu
    nix-output-monitor
    pokemon-colorscripts
    python3
    ripgrep
    starship
    trash-cli
    zellij
  ];

  programs.direnv.enable = true;
  programs.neovim = {
    enable = true;
    vimAlias = true;
    viAlias = true;
    withRuby = true;
    withPython3 = true;
    extraPackages =
      with pkgs;
      [
        clang
        cmake
        imagemagick
        lua51Packages.luarocks
        lua5_1
        nodejs
        tree-sitter
      ]
      ++ (
        if isLinux then
          [
            xclip
            wl-clipboard
          ]
        else
          [ ]
      );
  };

  # Environment Variables
  systemd.user.sessionVariables = {
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # Initial Home Manager Version, do *not* change.
  home.stateVersion = "25.11"; # Did you read the comment?
}
