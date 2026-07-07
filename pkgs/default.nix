{
  pkgs,
  kernelPackages ? true,
}:
let
  files' = builtins.attrNames (
    removeAttrs (builtins.readDir ./.) [
      "default.nix"
      "_qt5"
      "_kernel"
    ]
  );
  qt5' = builtins.attrNames (
    removeAttrs (builtins.readDir ./_qt5/.) [
      "default.nix"
    ]
  );
  kernel' = builtins.attrNames (
    removeAttrs (builtins.readDir ./_kernel/.) [
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
# i am guarding against the kernelPackages attrset for nix flake show
// (
  if kernelPackages then
    builtins.listToAttrs (
      map (file: {
        name = file;
        value = pkgs.callPackage ./_kernel/${file} { };
      }) kernel'
    )
  else
    builtins.listToAttrs (
      map (file: {
        name = file;
        value = (pkgs.callPackage ./_kernel/${file} { }).kernel;
      }) kernel'
    )
)
