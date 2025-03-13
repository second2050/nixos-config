{
  config,
  pkgs,
  ...
}:
{
  programs.plasma = {
    enable = true;
    overrideConfig = false;

    workspace = {
      # lookAndFeel = "org.kde.breezedark.desktop";
      cursor = {
        theme = "breeze_cursors";
        size = 24;
      };
      colorScheme = "Grey";
      windowDecorations = {
        library = "org.kde.darkly";
        theme = "Darkly";
      };
    };

    # Application Style
    configFile = {
      "kdeglobals"."KDE"."widgetStyle" = "Darkly";
    };

    kwin = {
      titlebarButtons = {
        left = [ "close" "minimize" "maximize" ];
        right = [ "on-all-desktops" "keep-above-windows" ];
      };
      borderlessMaximizedWindows = true;
      effects = {
        dimAdminMode.enable = true;
        desktopSwitching.animation = "slide";
      };
    };

    fonts = {
      general = {
        family = "Comfortaa";
        pointSize = 10;
      };
      fixedWidth = {
        family = "Delugia";
        pointSize = 10;
      };
    };

    panels = [
      {
        location = "top";
        widgets = [
          {
            name = "org.kde.windowbuttons";
            config = {
              General = {
                buttonSizePercentage = "55";
                visibility = "ActiveMaximizedWindow";
              };
            };
          }
          {
            name = "org.kde.windowtitle";
            config = {
              Appearance = {
                activityIcon = "false";
                altTxt = "Plasma Desktop";
                customIcon = "nix-snowflake-white";
                isBold = "true";
                isCaps = "true";
                txt = "%a";
              };
            };
          }
          "org.kde.plasma.appmenu"
          "org.kde.plasma.panelspacer"
          "org.kde.plasma.marginsseparator"
          "org.kde.plasma.kimpanel"
          {
            systemTray.items = {
              shown = [
                "org.kde.plasma.battery"
                "org.kde.plasma.bluetooth"
                "org.kde.plasma.networkmanagement"
                "org.kde.plasma.volume"
              ];
            };
          }
          {
            digitalClock = {
              calendar.firstDayOfWeek = "monday";
              time.format = "24h";
              date.format = "isoDate";
            };
          }
        ];
      }
      {
        location = "left";
        alignment = "center";
        hiding = "dodgewindows";
        lengthMode = "fit";
        height = 64;
        opacity = "translucent";
        floating = true;
        widgets = [
          {
            kickoff = {
              sortAlphabetically = true;
              icon = "nix-snowflake-white";
            };
          }
          {
            iconTasks = {
              iconsOnly = true;
              behavior = {
                showTasks = {
                  onlyInCurrentScreen = true;
                  onlyInCurrentDesktop = false;
                  onlyInCurrentActivity = true;
                  onlyMinimized = false;
                };
                unhideOnAttentionNeeded = true;
              };
              launchers = [
                "applications:zen.desktop"
                "applications:org.kde.dolphin.desktop"
              ];
            };
          }
          "org.kde.plasma.marginsseparator"
          "org.kde.plasma.trash"
        ];
      }
    ];

    configFile = {
      kwinrc = {
        Wayland."InputMethod" = "/run/current-system/sw/share/applications/org.fcitx.Fcitx5.desktop";
        Effect-slide = {
          HorizontalGap = "0";
          SlideBackground = "false";
          VerticalGap = "0";
        };
        ElectricBorder = {};
      };
    };

    input.keyboard = {
      options = [
        "shift:both_capslock_cancel"
        "compose:caps"
      ];
    };
  };
}
