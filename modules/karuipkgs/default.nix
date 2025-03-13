{
  lib,
  # pkgs,
  stdenv,
  fetchzip,
  config,
  inputs,
  system,
  ...
}:
let
  inherit (lib) mkIf mkEnableOption mkDerivation;
  cfg = config.karui.additionalPkgs;
in {
  options.karui.additionalPkgs = {
    enable = mkEnableOption "karui’s custom packages";
  };
  config = mkIf (cfg.enable) {
    nixpkgs.overlays = [
      (final: prev:
      let
        version = "2404.23";
      in {
        delugia-code = final.mkDerivation {
          pname = "delugia-code";
          inherit version;

          src = fetchzip {
            url = "https://github.com/adam7/delugia-code/releases/download/v${version}/delugia-complete.zip";
            stripRoot = false;
            hash = "sha256-0kl948agrzy300xl2ay0n4skm00i1axwd3n8s7qyzq44qm5j8nw7";
          };

          installPhase = ''
            runHook preInstall

            install -Dm644 delugia-complete/*.ttf -t $out/share/fonts/truetype

            runHook postInstall
          '';

          meta = with lib; {
            description = "Monospaced font that includes programming ligatures and is designed to enhance the modern look and feel of the Windows Terminal";
            homepage = "https://github.com/adam7/delugia-code";
            # license = licenses.ofl;
            # platforms = platforms.all;
          };
        };
      })
    ];
  };
}
