args@{
  pkgs,
  inputs,
  userName,
  userHome,
  ...
}:
let
  # packages
  pokemon-colorscripts = pkgs.stdenvNoCC.mkDerivation {
    name = "pokemon-colorscripts";
    version = "1";
    src = pkgs.fetchzip {
      url = "https://gitlab.com/phoneybadger/pokemon-colorscripts/-/archive/5802ff67520be2ff6117a0abc78a08501f6252ad/pokemon-colorscripts-5802ff67520be2ff6117a0abc78a08501f6252ad.tar.gz";
      stripRoot = false;
      hash = "sha256-+dZI6GfqpM2+gMH25FrTNucPdmKg/d7HQiX0EHvquas=";
    };
    installPhase = ''
      runHook preInstall
      cd pokemon-colorscripts-5802ff67520be2ff6117a0abc78a08501f6252ad
      install -dm755 $out/share/$name
      cp -rf colorscripts $out/share/$name/
      install -Dm755 pokemon-colorscripts.py -t $out/share/$name/
      install -Dm644 pokemon.json -t $out/share/$name/
      install -dm755 $out/bin
      ln -sf $out/share/$name/pokemon-colorscripts.py $out/bin/$name
      runHook postInstall
    '';
  };
  difftastic-aarch64-fixed = pkgs.difftastic.overrideAttrs (oldAttrs: {
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
    difftastic-aarch64-fixed
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
