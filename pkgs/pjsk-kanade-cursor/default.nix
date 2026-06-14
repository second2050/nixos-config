{
  fetchzip,
  lib,
  stdenvNoCC,
  win2xcur,
  scale ? "1",
  ...
}:
stdenvNoCC.mkDerivation rec {
  name = "pjsk-kanade-cursor";
  meta = {
    description = "Project Sekai Kanade Yoisaki Cursor";
    homepage = "https://www.colorfulstage.com/media/download/";
    platforms = lib.platforms.linux;
    license = lib.licenses.unfree;
  };
  version = "1.0.0";
  src = fetchzip {
    url = "https://www.colorfulstage.com/upload_images/media/Download/Kanade%20Cursor%20animation.zip";
    hash = "sha256-53L5eRbxny4Jy0f48WAusUCrBup52bsJhZhJaSDDab8=";
    stripRoot = false;
  };
  nativeBuildInputs = [
    win2xcur
  ];
  buildPhase = ''
    mkdir output
    win2xcurtheme install.inf -o output --scale ${toString scale}
  '';
  installPhase = ''
    runHook preInstall
    mkdir -p $out/share/icons/${name}
    cp -r output $out/share/icons/${name}/cursors
    cat <<EOF > $out/share/icons/${name}/index.theme
    [Icon Theme]
    Name = ${name}
    Comment = ${meta.description}
    EOF
  '';
}
