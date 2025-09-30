pkgs:
let
  files' = builtins.attrNames (
    builtins.removeAttrs (builtins.readDir ./.) [
      "default.nix"
      "_qt5"
    ]
  );
  qt5' = builtins.attrNames (
    builtins.removeAttrs (builtins.readDir ./_qt5/.) [
      "default.nix"
    ]
  );
in
builtins.listToAttrs (
  map (file: {
    name = file;
    value = pkgs.callPackage ./${file} { };
  }) files'
)
// builtins.listToAttrs (
  map (file: {
    name = file;
    value = pkgs.libsForQt5.callPackage ./_qt5/${file} { };
  }) qt5'
)
