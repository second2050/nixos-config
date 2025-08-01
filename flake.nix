{
  description = "Karui’s nixOS configuration";

  inputs = {
    # nixpkgs
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    # hardware modules
    nixos-apple-silicon = {
      url = "github:tpwrules/nixos-apple-silicon";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # third party modules
    lix-module = {
      url = "git+https://git.lix.systems/lix-project/nixos-module?ref=release-2.93";
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
      mkOsConfig =
        {
          system,
          hostModule,
          extraModules ? [ ],
        }:
        let
          specialArgs = { inherit self inputs system; };
          modules = [
            ./hosts/${hostModule}
          ]
          ++ [
            ./modules
            evyspkgs.nixosModules.default
            lix-module.nixosModules.default
            home-manager.nixosModules.home-manager
            flake-programs-sqlite.nixosModules.programs-sqlite
          ]
          ++ extraModules;
        in
        nixpkgs.lib.nixosSystem { inherit system modules specialArgs; };
      mkHomeConfig =
        {
          system ? null,
          pkgs ? nixpkgs.legacyPackages.${system},
          userName,
          userHome,
          extraModules ? [ ],
        }:
        let
          inherit pkgs;
          extraSpecialArgs = { inherit inputs userName userHome; };
          modules = [
            ./modules/home
            { home.packages = [ pkgs.fish ]; }
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
            nixfmt-rfc-style
            nh
            git
          ];
        };
      });

      # system configurations
      nixosConfigurations = {
        ringo = mkOsConfig {
          system = "aarch64-linux";
          hostModule = "ringo";
          extraModules = [
            (inputs.nixos-apple-silicon + /apple-silicon-support)
          ];
        };
        stargazer = mkOsConfig {
          system = "x86_64-linux";
          hostModule = "stargazer";
          extraModules = [ ];
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
      }
      // eachSystem (
        pkgs:
        mkHomeConfig {
          inherit pkgs;
          userName = builtins.getEnv "USER";
          userHome = builtins.getEnv "HOME";
        }
      );
    };
}
