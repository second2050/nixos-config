{
  config = {
    allowUnfree = true;
    permittedInsecurePackages = [
      "electron-39.8.10" # logseq
      "electron-40.10.5" # vesktop
    ];
    problems.handlers = {
      "gtk+".broken = "warn";
    };
  };
  overlays = [
    (final: _prev: {
      # replace insecure pnpm version
      pnpm_10_29_2 = final.pnpm_10;
    })
    (final: prev: {
      contour = (
        prev.contour.overrideAttrs rec {
          version = "master" + "-" + builtins.substring 0 7 src.rev;
          src = final.fetchFromGitHub {
            owner = "contour-terminal";
            repo = "contour";
            rev = "3c9e024cdc599916cdccb8cb2e965fbcc4c3325c";
            hash = "sha256-2l4shEZdmoITmTSDym7Wt+HTCM5szURa27z3xBHt1yA=";
          };
          patches = [ ];
          cmakeFlags = prev.contour.cmakeFlags ++ [
            (final.lib.cmakeBool "CONTOUR_EXTENSIONS" false)
            (final.lib.cmakeFeature "CONTOUR_NERD_FONT_SYMBOLS" "OFF")
            (final.lib.cmakeFeature "CONTOUR_EMOJI_FONT" "OFF")
          ];
          buildInputs = prev.contour.buildInputs ++ [
            final.glaze
          ];
        }
      );
      contour-daemon = (
        final.contour.overrideAttrs {
          cmakeFlags = final.contour.cmakeFlags ++ [
            (final.lib.cmakeBool "CONTOUR_FRONTEND_GUI" false)
          ];
        }
      );
      libunicode = (
        prev.libunicode.overrideAttrs rec {
          version = "0.9.5";
          src = final.fetchFromGitHub {
            owner = "contour-terminal";
            repo = "libunicode";
            rev = "v${version}";
            hash = "sha256-C4W5iif5TNMFyfG/3czqo/uzKjuSi+gGmljjzbX6ic8=";
          };
        }
      );
    })
  ];
}
