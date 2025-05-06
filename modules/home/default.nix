{
  config,
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
  pokemon-colorscripts = pkgs.stdenvNoCC.mkDerivation rec {
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
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "${karuiOpts.base.user.username}";
  home.homeDirectory = "${homeDirectory}";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "24.11"; # Please read the comment before changing.

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = with pkgs; [
    bat
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
    vesktop
    wl-clipboard
    zellij
    zen-browser.packages.aarch64-linux.default
  ];

  programs.direnv.enable = true;

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
  };

  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'. These will be explicitly sourced when using a
  # shell provided by Home Manager. If you don't want to manage your shell
  # through Home Manager then you have to manually source 'hm-session-vars.sh'
  # located at either
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/karui/etc/profile.d/hm-session-vars.sh
  systemd.user.sessionVariables = {
    GOLDWARDEN_SOCKET_PATH = "${homeDirectory}/.goldwarden.sock";
    GOLDWARDEN_SSH_AUTH_SOCKET = "${homeDirectory}/.goldwarden-ssh-agent.sock";
    SSH_AUTH_SOCK = "${homeDirectory}/.goldwarden-ssh-agent.sock";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
