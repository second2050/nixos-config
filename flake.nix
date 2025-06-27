{
  description = "Karui’s nixOS configuration";

  inputs = {
    # nixpkgs
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    # hardware modules
    nixos-apple-silicon = {
      url = "github:tpwrules/nixos-apple-silicon";
      # url = "github:second2050/nixos-apple-silicon";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    apple-silicon-firmware = {
      url = "path:/boot/asahi";
      flake = false;
    };

    # third party modules
    lix-module = {
      url = "git+https://git.lix.systems/lix-project/nixos-module?ref=release-2.92";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
    darkly-qt = {
      url = "github:Bali10050/Darkly";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    evyspkgs = {
      url = "gitlab:evysnix/evyspkgs";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    plasma-manager = {
      url = "github:nix-community/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
    kwin-effects-forceblur = {
      url = "github:taj-ny/kwin-effects-forceblur";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-programs-sqlite = {
      url = "github:wamserma/flake-programs-sqlite";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      lix-module,
      home-manager,
      zen-browser,
      nixos-apple-silicon,
      apple-silicon-firmware,
      darkly-qt,
      evyspkgs,
      plasma-manager,
      kwin-effects-forceblur,
      flake-programs-sqlite,
    }@inputs:
    let
      eachSystem =
        f:
        nixpkgs.lib.genAttrs nixpkgs.lib.systems.flakeExposed (system: f nixpkgs.legacyPackages.${system});
    in
    {
      # nix development shell
      devShells = eachSystem (pkgs: {
        default = pkgs.mkShellNoCC {
          name = "nix-configuration";
          packages = [
            pkgs.nixfmt-rfc-style
            pkgs.nh
            pkgs.git
          ];
        };
      });

      # system configurations
      nixosConfigurations.ringo =
        let
          system = "aarch64-linux";
          specialArgs = {
            inherit
              self
              inputs
              system
              ;
          };
          modules = [
            (inputs.nixos-apple-silicon + /apple-silicon-support)
            ./hosts/ringo
            ./modules
            evyspkgs.nixosModules.default
            lix-module.nixosModules.default
            home-manager.nixosModules.home-manager
            inputs.flake-programs-sqlite.nixosModules.programs-sqlite
          ];
        in
        nixpkgs.lib.nixosSystem { inherit system modules specialArgs; };

      # home configurations
      homeConfigurations = eachSystem (
        pkgs:
        home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          extraSpecialArgs = {
            inherit inputs;
            userName = builtins.getEnv "USER";
            userHome = builtins.getEnv "HOME";
          };
          modules = [
            ./modules/home
            { home.packages = [ pkgs.fish ]; }
          ];
        }
      );
    };
}
