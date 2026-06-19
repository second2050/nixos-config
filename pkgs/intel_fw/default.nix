{
  rustPlatform,
  fetchFromGitHub,
  ...
}:
rustPlatform.buildRustPackage rec {
  pname = "intel_fw";
  version = "0.1.2";
  src = fetchFromGitHub {
    owner = "platform-system-interface";
    repo = "intel_fw";
    rev = "v${version}";
    hash = "sha256-eOJDbRwq4ilbRSmfKfZ95qyUvnPYZrwt+BhGCzij2R8=";
  };

  cargoHash = "sha256-PLqvgG8qasbuE15EuiDlFaaU6Jm0UnODspCW1OZrE/I=";
}
