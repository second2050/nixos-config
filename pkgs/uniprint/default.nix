{
  stdenvNoCC,
  fetchzip,
  lib,
  ...
}:
let
  revision = "8e630c60a86ad0c992319e06f3439f7f286bd3ad";
in
stdenvNoCC.mkDerivation rec {
  name = "uniprint";
  meta = {
    description = "A shell script to print on the IRB printers of the TU Dortmund";
    homepage = "https://gitlab.fachschaften.org/tudo-fsinfo/admin/uniprint-fsr";
    platforms = lib.platforms.all;
    license = lib.licenses.asl20;
  };
  version = "1";
  src = fetchzip {
    url = "${meta.homepage}/-/archive/${revision}/uniprint-fsr-${revision}.tar.gz";
    stripRoot = true;
    hash = "sha256-EbD3g/FSsV+GA559PZOCwhUFXflaAql/KbMXa75Mn/I=";
  };
  installPhase = ''
    runHook preInstall
    ls -lah
    install -Dm755 uniprint $out/bin/$name
    runHook postInstall
  '';
}
