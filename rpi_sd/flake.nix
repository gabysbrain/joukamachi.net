{
  description = "RPi SD card build image";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.05";
  };

  outputs = { self, nixpkgs }: rec {
    nixosConfigurations.rpi = nixpkgs.lib.nixosSystem {
      modules = [
        "${nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"
        {
          nixpkgs.config.allowUnsupportedSystem = true;
          nixpkgs.hostPlatform.system = "aarch64-linux";
          nixpkgs.buildPlatform.system = "x86_64-linux"; #If you build on x86 other wise changes this.

          sdImage.compressImage = false;
        }
        ./base-config.nix
        ../includes/common.nix
      ];
    };
    images.rpi = nixosConfigurations.rpi.config.system.build.sdImage;

  };
}
