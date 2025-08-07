{
  stdenvNoCC,
  fetchgit,
  ...
}:
stdenvNoCC.mkDerivation {
  name = "kosugi-maru";
  meta = {
    description = "Font with a Gothic Rounded design, with low stroke contrast and monospaced metrics, and rounded terminals";
    homepage = "https://github.com/googlefonts/kosugi-maru";
  };
  version = "4.001";
  src = fetchgit {
    url = "https://github.com/googlefonts/kosugi-maru.git";
    rev = "bd22c671a9ffc10cc4313e6f2fd75f2b86d6b14b";
    hash = "sha256-gMilWV4t/yB3TtMe30IXHUlmSJDkD2THYUfbt3eT+h0=";
  };
  installPhase = ''
    runHook preInstall
    mkdir -p $out/share/X11/fonts
    cp -r fonts/ttf/*.ttf $out/share/X11/fonts/
    cp -r fonts/otf/*.otf $out/share/X11/fonts/
    runHook postInstall
  '';
}
