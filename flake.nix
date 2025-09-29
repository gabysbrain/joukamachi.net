{
  description = "Home network full of delicious servers";

  nixConfig = {
    extra-substituters = [
      "https://cachix.joukamachi.net/prod"
    ];
    extra-trusted-public-keys = [
      "prod:YvdQaSxvCua1bSMOD3JQj7eexVTZhmeHWWY842+T+aM="
    ];
  };

  inputs = {
    devshell.url = "github:numtide/devshell";
    flake-utils.url = "github:numtide/flake-utils";

    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";
    #nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    nixos-hardware.url = "github:nixos/nixos-hardware";

    # secrets, shhhh
    agenix.url = "github:ryantm/agenix";
    agenix.inputs.nixpkgs.follows = "nixpkgs";

    # Adblocking option for unbound DNS server
    adblock-unbound = {
      url = "github:mirosval/unbound-blocklist";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };
  };

  outputs = { self, devshell, flake-utils, nixos-hardware, nixpkgs, agenix, adblock-unbound, ... }: {
    nixosConfigurations.kura = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [ 
        ./kura-configuration.nix
        agenix.nixosModules.default
        adblock-unbound.nixosModules.default
      ];
    };
    nixosConfigurations.apple = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [ 
        # rpi stuff
        #"${nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"
        {
          nixpkgs.config.allowUnsupportedSystem = true;
          nixpkgs.hostPlatform.system = "aarch64-linux";
          nixpkgs.buildPlatform.system = "x86_64-linux"; #If you build on x86 other wise changes this.
        }
        # actual system stuff
        ./apple-configuration.nix
        agenix.nixosModules.default
        adblock-unbound.nixosModules.default
      ];
    };
    nixosConfigurations.bananacreme = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [ 
        # rpi stuff
        #"${nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"
        {
          nixpkgs.config.allowUnsupportedSystem = true;
          nixpkgs.hostPlatform.system = "aarch64-linux";
          nixpkgs.buildPlatform.system = "x86_64-linux"; #If you build on x86 other wise changes this.
        }
        # actual system stuff
        ./bananacreme-configuration.nix
        agenix.nixosModules.default
      ];
    };
    nixosConfigurations.cherry = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [ 
        # rpi stuff
        nixos-hardware.nixosModules.raspberry-pi-4
        #"${nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"
        {
          nixpkgs.config.allowUnsupportedSystem = true;
          nixpkgs.hostPlatform.system = "aarch64-linux";
          nixpkgs.buildPlatform.system = "x86_64-linux"; #If you build on x86 other wise changes this.
        }
        # actual system stuff
        ./cherry-configuration.nix
        agenix.nixosModules.default
        adblock-unbound.nixosModules.default
      ];
    };
    nixosConfigurations.pumpkin = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [ 
        # rpi stuff
        #"${nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"
        {
          nixpkgs.config.allowUnsupportedSystem = true;
          nixpkgs.hostPlatform.system = "aarch64-linux";
          nixpkgs.buildPlatform.system = "x86_64-linux"; #If you build on x86 other wise changes this.
        }
        # actual system stuff
        ./pumpkin-configuration.nix
        agenix.nixosModules.default
        adblock-unbound.nixosModules.default
      ];
    };
  } //
  # make numtide/devshell available as a package
  flake-utils.lib.eachDefaultSystem (system: {
    devShells.default = 
      let pkgs = import nixpkgs {
        inherit system;
        overlays = [ devshell.overlays.default ];
      };
      in
      pkgs.devshell.mkShell {
        imports = [ (pkgs.devshell.importTOML ./devshell.toml) ];
      };
  });

}
