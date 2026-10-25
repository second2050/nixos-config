{
  stdenvNoCC,
  fetchgit,
  lib,
  ...
}:
stdenvNoCC.mkDerivation rec {
  name = "kwin-scripts-temporary-virtual-desktops";
  pname = name;
  meta = {
    description = "KWin script to enable temporary virtual desktops";
    homepage = "https://github.com/Ubiquitine/temporary-virtual-desktops";
    platforms = lib.platforms.linux;
  };
  version = "0.5.0";
  src = fetchgit {
    url = "https://github.com/Ubiquitine/temporary-virtual-desktops.git";
    rev = "refs/tags/v${version}";
    hash = "sha256-9MpT4mFHdjFD4ZqD808CRzf8C6IPkuR0YVcTbgp2DA4=";
  };
  installPhase = ''
    runHook preInstall
    mkdir -p "$out/share/kwin/scripts/temporary-virtual-desktops"
    cp -r * "$out/share/kwin/scripts/temporary-virtual-desktops"
    runHook postInstall
  '';
}
