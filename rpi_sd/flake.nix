{
  description = "RPi SD card build image";

  inputs = {
    #nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
  };

  outputs =
    {
      self,
      nixpkgs,
    }@inputs:
    rec {
      nixosConfigurations.newpi = nixpkgs.lib.nixosSystem {
        system = "aarch64-linux";
        modules = [
          {
            system.stateVersion = "26.05";
          }
          ./base-config.nix
          ../includes/deploy.nix
          ../includes/rpi3.nix
        ];
      };

    };
}
