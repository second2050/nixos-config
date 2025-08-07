pkgs:
let
  files' = builtins.attrNames (
    builtins.removeAttrs (builtins.readDir ./.) [
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
