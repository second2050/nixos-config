{
  stdenvNoCC,
  fetchzip,
  lib,
  ...
}:
stdenvNoCC.mkDerivation {
  name = "pokemon-colorscripts";
  meta = {
    description = "CLI utility to print out images of pokemon to terminal";
    homepage = "https://gitlab.com/phoneybadger/pokemon-colorscripts";
    license = lib.licenses.mit;
  };
  version = "1";
  src = fetchzip {
    url = "https://gitlab.com/phoneybadger/pokemon-colorscripts/-/archive/5802ff67520be2ff6117a0abc78a08501f6252ad/pokemon-colorscripts-5802ff67520be2ff6117a0abc78a08501f6252ad.tar.gz";
    stripRoot = false;
    hash = "sha256-+dZI6GfqpM2+gMH25FrTNucPdmKg/d7HQiX0EHvquas=";
  };
  installPhase = ''
    runHook preInstall
    cd pokemon-colorscripts-5802ff67520be2ff6117a0abc78a08501f6252ad
    install -dm755 $out/share/$name
    cp -rf colorscripts $out/share/$name/
    install -Dm755 pokemon-colorscripts.py -t $out/share/$name/
    install -Dm644 pokemon.json -t $out/share/$name/
    install -dm755 $out/bin
    ln -sf $out/share/$name/pokemon-colorscripts.py $out/bin/$name
    runHook postInstall
  '';
}
