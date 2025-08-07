{
  stdenvNoCC,
  fetchzip,
  ...
}:
stdenvNoCC.mkDerivation rec {
  name = "kwin-effects-geometry-change";
  meta = {
    description = "KWin animation for windows moved or resized by programs or scripts";
    homepage = "https://github.com/peterfajdiga/kwin4_effect_geometry_change";
  };
  version = "1.4";
  src = fetchzip {
    url = "https://github.com/peterfajdiga/kwin4_effect_geometry_change/releases/download/v${version}/kwin4_effect_geometry_change_1_4.tar.gz";
    stripRoot = false;
    hash = "sha256-wPgB1ojLNNAnWA7916qBq12VdhEbwvRA1fwb27tZYQk=";
  };
  installPhase = ''
    runHook preInstall
    mkdir -p "$out/share/kwin/effects/kwin4_effect_geometry_change"
    cp -r package/* "$out/share/kwin/effects/kwin4_effect_geometry_change"
    runHook postInstall
  '';
}
