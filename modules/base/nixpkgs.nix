{
  config = {
    allowUnfree = true;
    permittedInsecurePackages = [
      "electron-39.8.10" # logseq
      "electron-40.10.5" # vesktop
    ];
  };
  overlays = [
    (final: _prev: {
      # replace insecure pnpm version
      pnpm_10_29_2 = final.pnpm_10;
    })
    (final: prev: {
      kara = (
        prev.kara.overrideAttrs rec {
          version = "64a843c82cfca7e278727aede3801a04dd95556c";
          src = final.fetchFromGitHub {
            owner = "dhruv8sh";
            repo = "kara";
            rev = "${version}";
            hash = "sha256-UZ3D4FtDuF4wT2EmnbioyHu19wVNYl0mQNZly5b4Mik=";
          };
        }
      );
    })
  ];
}
