{
  stdenv,
  fetchgit,
  lib,
  qtbase,
  wrapQtAppsHook,
  ...
}:
stdenv.mkDerivation rec {
  name = "ddctoolbox";
  meta = {
    description = "Create and edit DDC headset correction files";
    homepage = "https://github.com/timschneeb/DDCToolbox";
    platforms = lib.platforms.all;
    license = lib.licenses.gpl3;
  };
  version = "2.0.1";
  src = fetchgit {
    url = "${meta.homepage}.git";
    rev = "refs/tags/${version}";
    fetchSubmodules = true;
    hash = "sha256-w/FfFzp3UD9GnodKRNGqI5L/q0yzML7R9jvNEAgTaGI=";
  };
  buildInputs = [
    qtbase
  ];
  nativeBuildInputs = [
    wrapQtAppsHook
  ];
  buildPhase = ''
    qmake DDCToolbox.pro "CONFIG += no_tests"
    make
  '';
  installPhase = ''
    runHook preInstall
    install -Dm755 ./src/DDCToolbox "$out/bin/$name"
    install -Dm644 ./res/img/ddctoolbox.svg "$out/share/icons/hicolor/scalable/apps/$name.svg"
    mkdir -p $out/share/applications
    cat <<EOT >> $out/share/applications/${name}.desktop
    [Desktop Entry]
    Name=DDC Toolbox
    GenericName=DDC Editor
    Comment=${meta.description}
    Keywords=editor
    Categories=AudioVideo;Audio;Editor
    Exec=$out/bin/ddctoolbox
    Icon=$out/share/icons/hicolor/scalable/apps/$name.svg
    StartupNotify=false
    Terminal=false
    Type=Application
    EOT
    runHook postInstall
  '';
}
