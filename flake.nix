{
  description = "Home network full of delicious servers";

  # For accessing `deploy-rs`'s utility Nix functions

  inputs = {
    devshell.url = "github:numtide/devshell";
    flake-utils.url = "github:numtide/flake-utils";

    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";
    #nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    deploy-rs.url = "github:serokell/deploy-rs";
    deploy-rs.inputs.nixpkgs.follows = "nixpkgs";

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

  outputs = { self, devshell, flake-utils, nixpkgs, deploy-rs, agenix, adblock-unbound, ... }: {
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

    deploy = {
      sshUser = "deploy";
      sshOpts = [ "-i" "~/keys/id_deploy" ];
      user = "root";
      autoRollback = false;
      magicRollback = false;

      keepResult = true;

      nodes = {

        kura = {
          hostname = "kura.joukamachi.net";

          # base profile for the system
          profiles.system = {
            path = deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.kura;
            fastConnection = true;
          };

          # here we can list additonal service profiles
          # TODO: learn more about these and use them!
        };

        apple = {
          hostname = "apple.joukamachi.net";

          # base profile for the system
          profiles.system = {
            path = deploy-rs.lib.aarch64-linux.activate.nixos self.nixosConfigurations.apple;
            fastConnection = true;
          };
        };

        bananacreme = {
          hostname = "bananacreme.joukamachi.net";

          # base profile for the system
          profiles.system = {
            path = deploy-rs.lib.aarch64-linux.activate.nixos self.nixosConfigurations.bananacreme;
            fastConnection = true;
          };
        };

        cherry = {
          hostname = "cherry.joukamachi.net";

          # base profile for the system
          profiles.system = {
            path = deploy-rs.lib.aarch64-linux.activate.nixos self.nixosConfigurations.cherry;
            fastConnection = true;
          };
        };

        pumpkin = {
          hostname = "pumpkin.joukamachi.net";

          # base profile for the system
          profiles.system = {
            path = deploy-rs.lib.aarch64-linux.activate.nixos self.nixosConfigurations.pumpkin;
            fastConnection = true;
          };
        };
      };
    };

    # This is highly advised, and will prevent many possible mistakes
    checks = builtins.mapAttrs (system: deployLib: deployLib.deployChecks self.deploy) deploy-rs.lib;
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
