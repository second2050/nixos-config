{
  description = "Karui’s nixOS configuration";

  inputs = {
    # nixpkgs
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    # hardware modules
    nixos-apple-silicon = {
      url = "github:tpwrules/nixos-apple-silicon";
    };
    apple-silicon-firmware = {
      url = "path:/boot/asahi";
      flake = false;
    };

    # external modules
    lix-module = {
      url = "https://git.lix.systems/lix-project/nixos-module/archive/2.92.0.tar.gz";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    lix-module,
    home-manager,
    zen-browser,
    nixos-apple-silicon,
    apple-silicon-firmware }@inputs: {
    nixosConfigurations.ringo = nixpkgs.lib.nixosSystem {
      specialArgs = { inherit inputs; };
      system = "aarch64-linux";
      modules = [
        (inputs.nixos-apple-silicon + /apple-silicon-support)
        ./configuration.nix
        # This is the important part -- add this line to your module list!
        lix-module.nixosModules.default
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.karui = import ./home.nix;
          home-manager.extraSpecialArgs = { inherit zen-browser; };
        }
      ];
    };
  };
}
