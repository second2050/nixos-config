args@{
  pkgs,
  inputs,
  userName,
  userHome,
  ...
}:
let
  # packages
  difftastic' =
    if pkgs.stdenv.targetPlatform.isAarch then
      pkgs.difftastic.overrideAttrs (oldAttrs: {
        preBuild = (oldAttrs.preBuild or "") + ''
          export JEMALLOC_SYS_WITH_LG_PAGE=16
        '';
      })
    else
      pkgs.difftastic;
in
{
  # User informations for Home Manager
  home.username = userName;
  home.homeDirectory = userHome;

  # Packages
  home.packages = with pkgs; [
    bat
    btop
    difftastic'
    git
    go
    jq
    lsd
    mommy
    nodejs
    pokemon-colorscripts
    python3
    ripgrep
    starship
    trash-cli
    tree-sitter
    wl-clipboard
    zellij
  ];

  programs.direnv.enable = true;
  programs.neovim = {
    enable = true;
    vimAlias = true;
    viAlias = true;
    extraPackages = [
      pkgs.clang
      pkgs.luarocks
    ];
  };

  # Environment Variables
  systemd.user.sessionVariables = {
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # Initial Home Manager Version, do *not* change.
  home.stateVersion = "24.11"; # Did you read the comment?
}
