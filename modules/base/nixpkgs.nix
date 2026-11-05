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
      kara = (
        prev.kara.overrideAttrs rec {
          version = "64a843c82cfca7e278727aede3801a04dd95556c";
          src = final.fetchFromGitHub {
            owner = "dhruv8sh";
            repo = "kara";
            rev = "${version}";
            hash = "sha256-UZ3D4FtDuF4wT2EmnbioyHu19wVNYl0mQNZly5b4Mik=";
          };
        }
      );
      kde-rounded-corners = (
        prev.kde-rounded-corners.overrideAttrs rec {
          version = "4867a0c849b8bc85a734525bb03a374c626e689a";
          src = final.fetchFromGitHub {
            owner = "matinlotfali";
            repo = "KDE-Rounded-Corners";
            rev = "${version}";
            hash = "sha256-yRylCT9scW1Tmw5yIpS7ejTBqx3YMK6GHSB6GiWeKck=";
          };
        }
      );
      contour = (
        prev.contour.overrideAttrs rec {
          version = "0.9.0" + "-" + builtins.substring 0 7 src.rev;
          src = final.fetchFromGitHub {
            owner = "contour-terminal";
            repo = "contour";
            rev = "23c72bc874d3d86f80ccde98bfb22710c14ad056";
            hash = "sha256-VFrG6wGk3A9Lw6xxwuPw1u1GmC0bPy+ZfcVjnnYAKoM=";
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
