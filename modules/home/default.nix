args@{
  pkgs,
  inputs,
  userName,
  userHome,
  ...
}:
let
  # packages
  difftastic' = pkgs.difftastic.overrideAttrs (oldAttrs: {
    preBuild = (oldAttrs.preBuild or "") + ''
      export JEMALLOC_SYS_WITH_LG_PAGE=16
    '';
  });
in
{
  # User informations for Home Manager
  home.username = userName;
  home.homeDirectory = userHome;

  # Packages
  home.packages = with pkgs; [
    bat
    btop
    (if stdenv.targetPlatform.isAarch then difftastic' else difftastic)
    git
    go
    jq
    lsd
    mommy
    pokemon-colorscripts
    python3
    ripgrep
    starship
    trash-cli
    wl-clipboard
    zellij
  ];

  programs.direnv.enable = true;
  programs.neovim = {
    enable = true;
    vimAlias = true;
    viAlias = true;
    extraPackages = with pkgs; [
      clang
      luarocks
      nodejs
      tree-sitter
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
