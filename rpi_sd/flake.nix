{
  description = "RPi SD card build image";

  inputs = {
    #nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";
    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixos-generators,
    }:
    rec {
      nixosModules = {
        system = {
          disabledModules = [
            #"profiles/base.nix"
          ];

          system.stateVersion = "23.11";
        };
      };

      packages.aarch64-linux = {
        sdcard = nixos-generators.nixosGenerate {
          system = "aarch64-linux";
          format = "sd-aarch64";
          modules = [
            self.nixosModules.system
            ./base-config.nix
            ../includes/deploy.nix
            ../includes/rpi3.nix
          ];
        };
      };
    };
}
