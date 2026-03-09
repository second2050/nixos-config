{
  stdenvNoCC,
  fetchFromGitHub,
  lib,
  ...
}:
stdenvNoCC.mkDerivation rec {
  name = "eleven-icon-theme";
  meta = {
    description = "Windows 11 Style icon theme for Linux Desktop";
    homepage = "https://github.com/mjkim0727/Eleven-icon-theme";
    platforms = lib.platforms.linux;
    license = lib.licenses.gpl3;
  };
  version = "1.8";
  src = fetchFromGitHub {
    owner = "mjkim0727";
    repo = "Eleven-icon-theme";
    rev = "328d871a44da32f454d138bf74085999da23e1e3";
    hash = "sha256-dk41jno3lIiUA3dx5YbkG5maYkx4fBA0HTzuRoR+38o=";
  };
  phases = [
    "unpackPhase"
    "installPhase"
  ];
  installPhase = ''
    runHook preInstall
    mkdir -p $out/share/icons
    cp -r src/Eleven $out/share/icons/Eleven
    cp -r src/Eleven-Dark $out/share/icons/Eleven-Dark
    cp -r src/Eleven-Light $out/share/icons/Eleven-Light
  '';
}
