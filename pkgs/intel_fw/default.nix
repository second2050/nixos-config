{
  rustPlatform,
  fetchFromGitHub,
  ...
}:
rustPlatform.buildRustPackage rec {
  pname = "intel_fw";
  version = "0.2.0";
  src = fetchFromGitHub {
    owner = "platform-system-interface";
    repo = "intel_fw";
    rev = "v${version}";
    hash = "sha256-pB1yMQiIT99eOLLDplHjXE2zQK+oMWz+Gmtjs4MmfWQ=";
  };

  cargoHash = "sha256-5pvQOXt98xuc9prZWfEMYgc8qjqjc3zc9czBHEk9R7Q=";
}
