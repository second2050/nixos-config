{
  rust = {
    path = ./rust;
    description = "Rust template, using Naersk";
    welcomeText = ''
      # initialize project
      - run `nix develop` and `cargo init . && git add flake.nix`

      # how to use
      - build project via `nix build .` (or `cargo build`)
      - run porject via `nix run .` (or `cargo run`)
    '';
  };
}
