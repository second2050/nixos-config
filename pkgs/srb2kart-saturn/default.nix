{
  lib,
  stdenv,
  fetchzip,
  fetchFromGitHub,
  cmake,
  curl,
  nasm,
  game-music-emu,
  libpng,
  SDL2,
  SDL2_mixer,
  zlib,
  makeWrapper,
  makeDesktopItem,
  copyDesktopItems,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "srb2kart-saturn";
  version = "8.3";

  src = fetchFromGitHub {
    owner = "Indev450";
    repo = "SRB2Kart-Saturn";
    rev = "v${finalAttrs.version}";
    hash = "sha256-5sIHdeenWZjczyYM2q+F8Y1SyLqL+y77yxYDUM3dVA0=";
  };

  assets = stdenv.mkDerivation {
    pname = "srb2kart-data";
    version = "v1.6";

    src = fetchzip {
      url = "https://github.com/STJr/Kart-Public/releases/download/v1.6/AssetsLinuxOnly.zip";
      hash = "sha256-yaVdsQUnyobjSbmemeBEyu35GeZCX1ylTRcjcbDuIu4=";
      stripRoot = false;
    };

    installPhase = ''
      runHook preInstall

      mkdir -p $out/share/srb2kart-saturn
      cp -r * $out/share/srb2kart-saturn

      runHook postInstall
    '';
  };

  nativeBuildInputs = [
    cmake
    nasm
    makeWrapper
    copyDesktopItems
  ];

  buildInputs = [
    curl
    game-music-emu
    libpng
    SDL2
    SDL2_mixer
    zlib
  ];

  cmakeFlags = [
    "-DSRB2_ASSET_DIRECTORY=${finalAttrs.assets}/share/srb2kart-saturn"
    "-DGME_INCLUDE_DIR=${game-music-emu}/include"
    "-DSDL2_MIXER_INCLUDE_DIR=${lib.getDev SDL2_mixer}/include/SDL2"
    "-DSDL2_INCLUDE_DIR=${lib.getDev SDL2}/include/SDL2"
  ];

  desktopItems = [
    (makeDesktopItem rec {
      name = "Sonic Robo Blast 2 Kart Saturn";
      exec = "srb2kart-saturn";
      icon = "srb2kart-saturn";
      comment = "Modded SRB2Kart adding many custom features";
      desktopName = name;
      genericName = name;
      startupWMClass = ".srb2kart-saturn-wrapped";
      categories = [ "Game" ];
    })
  ];

  installPhase = ''
    runHook preInstall

    install -Dm644 ../srb2.png $out/share/pixmaps/srb2kart-saturn.png
    install -Dm644 ../srb2.png $out/share/icons/srb2kart-saturn.png
    install -Dm755 bin/srb2kart $out/bin/srb2kart-saturn

    wrapProgram $out/bin/srb2kart-saturn \
      --set SRB2WADDIR "${finalAttrs.assets}/share/srb2kart-saturn"

    runHook postInstall
  '';

  meta = with lib; {
    description = "Classic styled kart racer";
    homepage = "https://github.com/Indev450/SRB2Kart-Saturn";
    platforms = platforms.linux;
    license = licenses.gpl2Plus;
    maintainers = "karui";
    mainProgram = "srb2kart";
  };
})
