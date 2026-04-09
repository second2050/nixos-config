{
  description = "Karui’s nixOS configuration";

  inputs = {
    # nixpkgs
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    # hardware modules
    nixos-apple-silicon = {
      url = "github:nix-community/nixos-apple-silicon";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-hardware.url = "github:NixOS/nixos-hardware";

    # third party modules
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
      url = "github:xarblu/kwin-effects-better-blur-dx";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-programs-sqlite = {
      url = "github:wamserma/flake-programs-sqlite";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixgl = {
      url = "github:nix-community/nixGL";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      ...
    }@inputs:
    let
      eachSystem =
        f:
        nixpkgs.lib.genAttrs nixpkgs.lib.systems.flakeExposed (system: f nixpkgs.legacyPackages.${system});
      eachSystemTested =
        f:
        nixpkgs.lib.genAttrs [ "x86_64-linux" "aarch64-linux" "aarch64-darwin" ] (
          system: f nixpkgs.legacyPackages.${system}
        );
      mkOsConfig =
        {
          hostModule ? throw "hostModule is undefined!",
          extraModules ? [ ],
        }:
        let
          specialArgs = { inherit self inputs; };
          modules =
            with inputs;
            [
              ./hosts/${hostModule}
              ./modules
              self.nixosModules.packages
              evyspkgs.nixosModules.default
              home-manager.nixosModules.home-manager
              flake-programs-sqlite.nixosModules.programs-sqlite
            ]
            ++ extraModules;
        in
        nixpkgs.lib.nixosSystem { inherit modules specialArgs; };
      mkHomeConfig =
        {
          system ? throw "system is undefined!",
          pkgs ? nixpkgs.legacyPackages.${system},
          userName ? throw "username is undefined!",
          userHome ? throw "home directory is undefined!",
          flakeDir ? "${userHome}/.nixos-config",
          extraModules ? [ ],
        }:
        let
          inherit pkgs;
          extraSpecialArgs = {
            inherit
              self
              inputs
              userName
              userHome
              flakeDir
              ;
          };
          modules = [
            ./homeModules/base
            ./homeModules/standalone
            self.homeModules.packages
          ]
          ++ extraModules;
        in
        home-manager.lib.homeManagerConfiguration { inherit pkgs extraSpecialArgs modules; };
    in
    {
      # nix development shell
      devShells = eachSystem (pkgs: {
        default = pkgs.mkShellNoCC {
          name = "nix-configuration";
          packages = with pkgs; [
            nixfmt
            nixfmt-tree
            nh
            git
          ];
        };
      });
      formatter = eachSystem (pkgs: pkgs.nixfmt-tree);

      # system configurations
      nixosConfigurations = {
        ringo = mkOsConfig {
          hostModule = "ringo";
          extraModules = [
            inputs.nixos-apple-silicon.nixosModules.default
          ];
        };
        stargazer = mkOsConfig {
          hostModule = "stargazer";
          extraModules = with inputs; [
            nixos-hardware.nixosModules.common-cpu-amd-pstate
            nixos-hardware.nixosModules.common-cpu-amd-zenpower
          ];
        };
      };

      # home configurations
      homeConfigurations = {
        "second2050@airhead" = mkHomeConfig {
          system = "aarch64-darwin";
          userName = "second2050";
          userHome = "/Users/second2050";
        };
        "second2050@rddbn" = mkHomeConfig {
          pkgs = nixpkgs.legacyPackages.x86_64-linux;
          userName = "second2050";
          userHome = "/home/second2050";
        };
        "deck@karuis-deck" = mkHomeConfig {
          system = "x86_64-linux";
          userName = "deck";
          userHome = "/home/deck";
          extraModules = [
            ./homeModules/deck
            ./homeModules/desktop
          ];
        };
        "karui@obake" = mkHomeConfig {
          system = "x86_64-linux";
          userName = "karui";
          userHome = "/home/second2050";
        };
      }
      // eachSystem (
        pkgs:
        mkHomeConfig {
          inherit pkgs;
          userName = builtins.getEnv "USER";
          userHome = builtins.getEnv "HOME";
        }
      );

      # exported modules
      nixosModules.packages =
        { ... }:
        {
          config.nixpkgs.overlays = [
            self.overlays.packages
          ];
        };
      homeModules.packages =
        { ... }:
        {
          config.nixpkgs.overlays = [
            self.overlays.packages
          ];
        };

      # overlays
      overlays.packages = final: prev: import ./pkgs final;

      # packages
      packages = eachSystemTested (pkgs: import ./pkgs pkgs);

      # static assets
      assets = eachSystem (pkgs: import ./assets.nix { inherit pkgs; });

      # templates
      templates = import ./templates;

      # lib
      lib = {
        inherit
          eachSystem
          eachSystemTested
          mkHomeConfig
          mkOsConfig
          ;
      };
    };
}
