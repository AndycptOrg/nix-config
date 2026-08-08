{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    nixos-wsl.url = "github:nix-community/NixOS-WSL/main";
  };

  outputs = { nixpkgs, ... }@inputs: {
    templates = {
      rust = {
        path = ./templates/rust;
        description = "rust template";
      };
    };

    nixosConfigurations.NixOSBtw = nixpkgs.lib.nixosSystem {
      specialArgs = { inherit inputs; };
      system = "x86_64-linux";
      modules = [
        ./configuration.nix
      ];
    };
  };
}
