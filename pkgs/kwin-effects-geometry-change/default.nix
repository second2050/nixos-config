{
  stdenvNoCC,
  fetchzip,
  lib,
  ...
}:
stdenvNoCC.mkDerivation rec {
  name = "kwin-effects-geometry-change";
  pname = name;
  meta = {
    description = "KWin animation for windows moved or resized by programs or scripts";
    homepage = "https://github.com/peterfajdiga/kwin4_effect_geometry_change";
    platforms = lib.platforms.linux;
  };
  version = "1.5";
  src = fetchzip {
    url = "https://github.com/peterfajdiga/kwin4_effect_geometry_change/releases/download/v${version}/kwin4_effect_geometry_change_${
      lib.replaceString "." "_" version
    }.tar.gz";
    stripRoot = false;
    hash = "sha256-1xjG6tIaUj97T2yHq+W7MLcODS0BN/yOzKgpql1/q1k=";
  };
  installPhase = ''
    runHook preInstall
    mkdir -p "$out/share/kwin/effects/kwin4_effect_geometry_change"
    cp -r kwin4_effect_geometry_change/* "$out/share/kwin/effects/kwin4_effect_geometry_change"
    runHook postInstall
  '';
}
