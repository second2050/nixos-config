args@{
  pkgs,
  inputs,
  userName,
  userHome,
  ...
}:
{
  imports = [
    inputs.zen-browser.homeModules.beta
  ];

  home.packages = with pkgs; [
    goldwarden
    kdePackages.breeze
    logseq
    pinentry-qt
    signal-desktop
    usbkvm
    wl-clipboard
    youtube-music
    (
      if builtins.elem stdenv.targetPlatform.system discord.meta.platforms then
        discord.override {
          withOpenASAR = true;
          withVencord = true;
        }
      else
        vesktop
    )
  ];

  programs.zen-browser = {
    enable = true;
    nativeMessagingHosts = [
      pkgs.kdePackages.plasma-browser-integration
    ];
  };

  systemd.user.sessionVariables = {
    GOLDWARDEN_SOCKET_PATH = "${userHome}/.goldwarden.sock";
    GOLDWARDEN_SSH_AUTH_SOCKET = "${userHome}/.goldwarden-ssh-agent.sock";
    SSH_AUTH_SOCK = "${userHome}/.goldwarden-ssh-agent.sock";
    MOZ_ENABLE_WAYLAND = 1;
    MOZ_REMOTE_DBUS = 1;
  };
}
