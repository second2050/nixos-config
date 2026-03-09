{
  stdenvNoCC,
  fetchzip,
  lib,
  ...
}:
stdenvNoCC.mkDerivation rec {
  name = "applet-window-title6";
  version = "0.9.0";
  src = fetchzip {
    url = "https://github.com/dhruv8sh/plasma6-window-title-applet/archive/refs/tags/v${version}.tar.gz";
    stripRoot = false;
    hash = "sha256-YUnIKX5VlgC8vUdGwYPkzupIUxudAsBcf5tpK0tt0n8=";
  };
  postPatch = ''
    substituteInPlace plasma6-window-title-applet-${version}/contents/ui/main.qml \
      --replace-fail "import org.kde.plasma.private.appmenu 1.0 as AppMenuPrivate" ""
  '';
  installPhase = ''
    runHook preInstall
    mkdir -p "$out/share/plasma/plasmoids/org.kde.windowtitle"
    cp -r plasma6-window-title-applet-${version}/* "$out/share/plasma/plasmoids/org.kde.windowtitle"
    rm "$out/share/plasma/plasmoids/org.kde.windowtitle/README.md"
    runHook postInstall
  '';
  meta = {
    description = "Plasma 6 applet that shows the application title and icon for active window";
    homepage = "https://github.com/dhruv8sh/plasma6-window-title-applet";
    platforms = lib.platforms.linux;
  };
}
