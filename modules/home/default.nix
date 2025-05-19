{
  nixosConfig,
  pkgs,
  zen-browser,
  ...
}:
let
  karuiOpts = nixosConfig.karui;
  usersOpts = nixosConfig.users.users.${karuiOpts.base.user.username};
  homeDirectory = "${usersOpts.home}";
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
in
{
  imports = [
    ./plasma
  ];
  # User informations for Home Manager
  home.username = "${karuiOpts.base.user.username}";
  home.homeDirectory = "${homeDirectory}";

  # Packages
  home.packages = with pkgs; [
    bat
    btop
    difftastic
    go
    goldwarden
    jq
    logseq
    lsd
    mommy
    nodejs
    pinentry-qt
    pokemon-colorscripts
    python3
    ripgrep
    signal-desktop
    starship
    trash-cli
    tree-sitter
    vesktop
    wl-clipboard
    zellij
    zen-browser.packages.aarch64-linux.default
  ];

  programs.direnv.enable = true;

  # Environment Variables
  systemd.user.sessionVariables = {
    GOLDWARDEN_SOCKET_PATH = "${homeDirectory}/.goldwarden.sock";
    GOLDWARDEN_SSH_AUTH_SOCKET = "${homeDirectory}/.goldwarden-ssh-agent.sock";
    SSH_AUTH_SOCK = "${homeDirectory}/.goldwarden-ssh-agent.sock";
    MOZ_ENABLE_WAYLAND = 1;
    MOX_REMOTE_DBUS = 1;
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # Initial Home Manager Version, do *not* change.
  home.stateVersion = "24.11"; # Did you read the comment?
}
