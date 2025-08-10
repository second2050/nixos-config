args@{
  pkgs,
  inputs,
  userName,
  userHome,
  ...
}:
{
  home.packages = with pkgs; [
    goldwarden
    logseq
    pinentry-qt
    signal-desktop
    vesktop
    inputs.zen-browser.packages.${pkgs.system}.default
  ];

  systemd.user.sessionVariables = {
    GOLDWARDEN_SOCKET_PATH = "${userHome}/.goldwarden.sock";
    GOLDWARDEN_SSH_AUTH_SOCKET = "${userHome}/.goldwarden-ssh-agent.sock";
    SSH_AUTH_SOCK = "${userHome}/.goldwarden-ssh-agent.sock";
    MOZ_ENABLE_WAYLAND = 1;
    MOZ_REMOTE_DBUS = 1;
  };
}
