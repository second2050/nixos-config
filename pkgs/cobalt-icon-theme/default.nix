{
  stdenvNoCC,
  fetchzip,
  lib,
  ...
}:
stdenvNoCC.mkDerivation rec {
  name = "cobalt-icon-theme";
  meta = {
    description = "Windows 11 Style icons for Linux";
    homepage = "https://github.com/mjkim0727/Cobalt-icons";
    platforms = lib.platforms.linux;
    license = lib.licenses.gpl3;
  };
  version = "1.8";
  src = fetchzip {
    url = "${meta.homepage}/releases/download/1.3/Cobalt.tar.gz";
    stripRoot = false;
    hash = "sha256-tyGFAs5HYY86UoG8e4nNGcgRWYzAfgnPlhmzIrbCnPQ=";
  };
  phases = [
    "unpackPhase"
    "installPhase"
  ];
  installPhase = ''
    runHook preInstall
    mkdir -p $out/share/icons
    cp -r Cobalt $out/share/icons/Cobalt
    cp -r Cobalt-dark $out/share/icons/Cobalt-dark
    runHook postInstall
  '';
}
