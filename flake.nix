{
  description = "My NixOS flake, work in progress";

  inputs = {
    # Nixpkgs
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    # Also see the 'unstable-packages' overlay at 'overlays/default.nix'.

    # Home manager
    home-manager.url = "github:nix-community/home-manager/release-24.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    ...
  } @ inputs: let
    inherit (self) outputs;
    # Supported systems for flake packages, shell, etc.
    systems = [
      "x86_64-linux"
    ];
    # generates an attribute by calling a function you pass to it, with each system as an argument
    forAllSystems = nixpkgs.lib.genAttrs systems;
  in {
    # legacy packages
    packages = forAllSystems (system: import ./pkgs nixpkgs.legacyPackages.${system});
    # Formatter for your nix files, available through 'nix fmt' (this was in the template)
    formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.alejandra);

    # custom packages and modifications, exported as overlays
    overlays = import ./overlays {inherit inputs;};

    nixosModules = import ./modules/nixos;
    homeManagerModules = import ./modules/home-manager;

    # NixOS configuration entrypoint
    # 'nixos-rebuild --flake .#your-hostname'
    nixosConfigurations = {
      nixos = nixpkgs.lib.nixosSystem {
        specialArgs = {inherit inputs outputs;};
        modules = [
          # main nixos configuration file <
          ./nixos/configuration.nix
          # Add the Home Manager module
          home-manager.nixosModules.home-manager
          {
            # avoids duplicate packages
            home-manager.useUserPackages = true;

            # import the home manager config
            home-manager.users.davide = import ./home-manager/home.nix;

            # This line avoids the file conflict error
            home-manager.backupFileExtension = "backup";
          }
        ];
      };
    };
  };
}
