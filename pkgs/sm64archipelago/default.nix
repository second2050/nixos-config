{
  lib,
  gcc15Stdenv,
  fetchFromGitHub,
  fetchpatch,
  python3,
  pkg-config,
  audiofile,
  SDL2,
  libGL,
  cmake,
  hexdump,
  sm64baserom,
  region ? "us",
  _60fps ? true,
  _nonStop ? true,
  _extendedMoves ? true,
}:
let
  baseRom = (sm64baserom.override { inherit region; }).romPath;
in
gcc15Stdenv.mkDerivation (finalAttrs: {

  pname = "sm64archipelago";
  version = "0-unstable-2025-10-16";

  src = fetchFromGitHub {
    owner = "N00byKing";
    repo = "sm64ex";
    rev = "fe187c151aa608361d30d1819edca131c0043cf9";
    hash = "sha256-7+tp/2zhtaxtgzL6I8vQLRWyGIxsnrd+R9opcUhCObc=";
    fetchSubmodules = true;
  };

  patches =
    lib.optionals _60fps [
      (fetchpatch {
        name = "60fps_ex.patch";
        url = "file://${finalAttrs.src}/enhancements/60fps_ex.patch";
        hash = "sha256-2V7WcZ8zG8Ef0bHmXVz2iaR48XRRDjTvynC4RPxMkcA=";
      })
    ]
    ++ lib.optionals _nonStop [
      (fetchpatch {
        name = "nonstop_mode_always_enabled.patch";
        url = "file://${finalAttrs.src}/enhancements/nonstop_mode_always_enabled.patch";
        hash = "sha256-s9V8UeIcjNyczfNPmgawgCmKJUkdCItSEr1cQ3ZyX/Q=";
      })
    ]
    ++ lib.optionals _extendedMoves [
      (fetchpatch {
        name = "Extended.Moveset.v1.03b.sm64ex_archipelago.patch";
        url = "file://${finalAttrs.src}/enhancements/Extended.Moveset.v1.03b.sm64ex_archipelago.patch";
        hash = "sha256-kvsVZu5sXRJpya2BcnJOA+sgORBL3jK6YiZf/Gt3LlA=";
      })
    ];

  nativeBuildInputs = [
    python3
    pkg-config
    hexdump
  ];

  buildInputs = [
    audiofile
    SDL2
    libGL
    cmake
  ];

  enableParallelBuilding = true;
  dontUseCmakeConfigure = true;

  makeFlags = [
    "VERSION=${region}"
  ]
  ++ lib.optionals gcc15Stdenv.hostPlatform.isDarwin [
    "OSX_BUILD=1"
  ];

  preBuild = ''
    patchShebangs extract_assets.py
    ln -s ${baseRom} ./baserom.${region}.z64
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    mkdir -p $out/lib
    cp build/${region}_pc/sm64.${region}.f3dex2e $out/bin/sm64archipelago
    cp build/${region}_pc/libAPCpp.so $out/lib/

    runHook postInstall
  '';

  meta = {
    homepage = "https://github.com/N00byKing/sm64ex";
    description = "Super Mario 64 port based off of decompilation, with the Archipelago patchset";
    longDescription = ''
      Note that you must supply a baserom yourself to extract assets from.
      If you are not using an US baserom, you must overwrite the "region" attribute with either "eu" or "jp".
      If you would like to use patches sm64ex distributes as makeflags, add them to the "compileFlags" attribute.
    '';
    mainProgram = "sm64archipelago";
    license = lib.licenses.unfree;
    maintainers = "karui";
    platforms = lib.platforms.unix;
  };
})
