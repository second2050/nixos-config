{
  ...
}:
{
  programs.konsole = {
    enable = true;
    defaultProfile = "Zellij";

    profiles = {
      zellij = {
        name = "Zellij";
        command = "/usr/bin/env zellij --layout welcome";
        colorScheme = "monokai saturated";
        font = {
          name = "Monospace";
          size = 10;
        };
        extraConfig = {
          "General" = {
            "TerminalCenter" = "true";
            "TerminalMargin" = "2";
          };
          "Appearance" = {
            "BoldIntense" = "false";
            "WordMode" = true;
            "WordModeAscii" = false;
          };
          "Scrolling" = {
            "HighlightScrolledLines" = "false";
            "HistoryMode" = "0";
            "ScrollBarPosition" = "2";
          };
        };
      };
      fish = {
        name = "Fish";
        command = "/usr/bin/env fish";
        colorScheme = "monokai saturated";
        font = {
          name = "Monospace";
          size = 10;
        };
        extraConfig = {
          "General" = {
            "TerminalCenter" = "true";
            "TerminalMargin" = "2";
          };
          "Appearance" = {
            "BoldIntense" = "false";
            "WordMode" = true;
            "WordModeAscii" = false;
          };
        };
      };
    };

    customColorSchemes = {
      "monokai saturated" = ./monokai_saturated.colorscheme;
    };
  };
}
