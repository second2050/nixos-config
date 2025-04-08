{
  description = "Karui’s nixOS configuration";

  inputs = {
    # nixpkgs
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-2411.url = "github:nixos/nixpkgs/nixos-24.11";

    # hardware modules
    nixos-apple-silicon = {
      #url = "github:tpwrules/nixos-apple-silicon";
      url = "github:marcin-serwin/nixos-apple-silicon/push-nwvktpxoswts";
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
      nixpkgs-2411,
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
    {
      nixosConfigurations.ringo =
        let
          system = "aarch64-linux";
          pkgs-2411 = import nixpkgs-2411 { inherit system; };
          specialArgs = {
            inherit
              self
              inputs
              system
              pkgs-2411
              ;
          };
          modules = [
            (inputs.nixos-apple-silicon + /apple-silicon-support)
            ./hosts/ringo
            ./modules
            evyspkgs.nixosModules.default
            # This is the important part -- add this line to your module list!
            lix-module.nixosModules.default
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.sharedModules = [ plasma-manager.homeManagerModules.plasma-manager ];
              home-manager.users.karui = import ./modules/home;
              home-manager.extraSpecialArgs = { inherit zen-browser; };
            }
            inputs.flake-programs-sqlite.nixosModules.programs-sqlite
          ];
        in
        nixpkgs.lib.nixosSystem { inherit system modules specialArgs; };
    };
}
