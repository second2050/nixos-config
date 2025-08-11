{ ... }:
{
  programs.plasma = {
    input = {
      keyboard = {
        options = [
          "shift:both_capslock_cancel"
          "compose:caps"
        ];
      };
    };
    configFile.kwin.Wayland."InputMethod" =
      "/run/current-system/sw/share/applications/org.fcitx.Fcitx5.desktop";
  };

  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5 = {
      settings = {
        inputMethod = {
          GroupOrder = {
            "0" = "Default";
            "1" = "German";
          };
          "Groups/0" = {
            Name = "Default";
            "Default Layout" = "gb";
            DefaultIM = "mozc";
          };
          "Groups/0/Items/0".Name = "keyboard-gb";
          "Groups/0/Items/1".Name = "mozc";
          "Groups/1" = {
            Name = "German";
            "Default Layout" = "de";
            DefaultIM = "mozc";
          };
          "Groups/1/Items/0".Name = "keyboard-de";
          "Groups/1/Items/1".Name = "mozc";
        };
        globalOptions = {
          "Hotkey/TriggerKeys"."0" = "Control+space";
          "Hotkey/PrevPage"."0" = "Up";
          "Hotkey/NextPage"."0" = "Down";
          "Hotkey/PrevCandidate"."0" = "Shift+Tab";
          "Hotkey/NextCandidate"."0" = "Tab";
          "Hotkey/TogglePreedit"."0" = "Control+Alt+P";
        };
        addons = {
          # true and false are case sensitive for some reason...
          kimpanel.globalSection.PreferTextIcon = "True";
          classicui.globalSection = {
            "Vertical Candidate List" = "True";
            WheelForPaging = "True";
            Font = "Sans Serif 10";
            MenuFont = "Sans Serif 10";
            TrayFont = "Sans Bold 10";
            TrayOutlineColor = "#000000";
            TrayTextColor = "#ffffff";
            PreferTextIcon = "False";
            ShowLayoutNameInIcon = "True";
            UseInputMethodLanguageToDisplayText = "True";
            Theme = "plasma";
            DarkTheme = "plasma";
            UseDarkTheme = "True";
            UseAccentColor = "True";
            PerScreenDPI = "False";
            ForceWaylandDPI = 0;
            EnableFractionalScale = "True";
          };
        };
      };
    };
  };
}
