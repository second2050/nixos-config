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
            rev = "915b2689fa131b03173f3b086e0345257813d673";
            hash = "sha256-mb2+fPD3dPNCcWI7usKz6y5InSIM4r3cFOMMmbouf2E=";
          };
          patches = [ ];
          cmakeFlags = prev.contour.cmakeFlags ++ [
            (final.lib.cmakeBool "CONTOUR_EXTENSIONS" false)
            (final.lib.cmakeFeature "CONTOUR_NERD_FONT_SYMBOLS" "OFF")
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
