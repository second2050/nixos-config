{
  stdenvNoCC,
  fetchgit,
  ...
}:
stdenvNoCC.mkDerivation rec {
  name = "kwin-scripts-temporary-virtual-desktops";
  meta = {
    description = "KWin script to enable temporary virtual desktops";
    homepage = "https://github.com/Ubiquitine/temporary-virtual-desktops";
  };
  version = "0.4.0";
  src = fetchgit {
    url = "https://github.com/Ubiquitine/temporary-virtual-desktops.git";
    rev = "refs/tags/v${version}";
    hash = "sha256-PU3/FRa38/4bFMNSc7uhSYlHPqaZ9HMbjnTU9Z6O2JI=";
  };
  installPhase = ''
    runHook preInstall
    mkdir -p "$out/share/kwin/scripts/temporary-virtual-desktops"
    cp -r * "$out/share/kwin/scripts/temporary-virtual-desktops"
    runHook postInstall
  '';
}
