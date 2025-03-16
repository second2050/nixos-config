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
      wallpaper = ./wallpaper;
      cursor = {
        theme = "breeze_cursors";
        size = 24;
      };
      colorScheme = "Grey"; # Accent set in extra config.
      windowDecorations = {
        library = "org.kde.darkly";
        theme = "Darkly";
      };
    };

    kscreenlocker.appearance = {
      wallpaper = ./wallpaper;
      alwaysShowClock = true;
    };

    kwin = {
      titlebarButtons = {
        left = [ "close" "minimize" "maximize" ];
        right = [ "on-all-desktops" "keep-above-windows" ];
      };
      borderlessMaximizedWindows = true;
      effects = {
        blur.enable = false; # I am using Better Blur
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
      small = {
        family = "Comfortaa";
        pointSize = 8;
      };
      toolbar = {
        family = "Comfortaa";
        pointSize = 10;
      };
      menu = {
        family = "Comfortaa";
        pointSize = 10;
      };
      windowTitle = {
        family = "Comfortaa";
        pointSize = 10;
      };
    };

    shortcuts = {
      kwin = {
        "Window Maximize" = "Meta+Return";
        "Window Fullscreen" = "Meta+F";
        "Walk Through Windows" = "Alt+Tab";
        "Walk Through Windows (Reverse)" = "Alt+Shift+Tab";
        "Walk Through Windows Alternative" = "Meta+Tab";
        "Walk Through Windows Alternative (Reverse)" = "Meta+Shift+Tab";
      };
    };

    panels = [
      {
        location = "top";
        height = 42;
        widgets = [
          {
            name = "org.kde.windowbuttons";
            config = {
              General = {
                buttonSizePercentage = 55;
                visibility = "ActiveMaximizedWindow";
                selectedPlugin = "org.kde.darkly";
                useCurrentDecoration = false;
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
          {
            name = "org.dhruv8sh.kara";
            config = {
              general = {
                animationDuration = 100;
                highlightType = 2; # Text Indicator
              };
              type2 = {
                fixedLen = 1;
                labelSource = 7; # Chinese Numerals
              };
            };
          }
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
          {
            name = "org.kde.plasma.userswitcher";
            config = {
              General = {
                showFace = true;
                showName = false;
              };
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

    # Extra Config
    configFile = {
      kdeglobals = {
        KDE.widgetStyle = "Darkly"; # Application Style
        General.AccentColor = "233,58,154";
      };
      kwinrc = {
        Wayland."InputMethod" = "/run/current-system/sw/share/applications/org.fcitx.Fcitx5.desktop";
        # Additional Effect and Script Config
        Plugins = {
          forceblurEnabled = true; # Effect-blurplus
          temporary-virtual-desktopsEnabled = true;
          kwin4_effect_shapecornersEnabled = true; # Round-Corners
        };
        Effect-slide = {
          HorizontalGap = 0;
          SlideBackground = true;
          VerticalGap = 0;
        };
        Effect-blurplus = {
          BlurMatching = true;
          BlurNonMatching = false;
          FakeBlur = true; # fake blur is easier on the gpu
          FakeBlurDisableWhenWindowBehind = true;
          FakeBlurImageSourceDesktopWallpaper = false;
          BottomCornerRadius = 6;
          MenuCornerRadius = 6;
          TopCornerRadius = 6;
          WindowClasses = "zen"; # these will be force blurred
        };
        Round-Corners = {
          Size = 6; # ActiveCornerRadius
          ActiveOutlineAlpha = 255;
          ActiveOutlineUseCustom = false;
          ActiveOutlineUsePalette = true;
          OutlineThickness = 1.00;
          InactiveCornerRadius = 6;
          InactiveOutlineAlpha = 63;
          InactiveOutlineUseCustom = true;
          InactiveOutlineColor = "255,255,255";
          InactiveOutlineThickness = 1.00;
          SecondOutlineThickness = 0; 
        };
        Script-temporary-virtual-desktops = {
          oneSpare = true;
        };

        
        # Task Switcher
        TabBox = {
          LayoutName = "sidebar";
          DesktopMode = 1; # Show windows only from current desktop.
          orderMinimizedMode = 1; # Order minimized windows last
        };
        TabBoxAlternative = {
          LayoutName = "sidebar";
          DesktopMode = 0; # Show windows from all desktops.
          orderMinimizedMode = 1; # Order minimized windows last
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
