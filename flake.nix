{
  description = "Home network full of delicious servers";

  # For accessing `deploy-rs`'s utility Nix functions

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.11";
    #nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    deploy-rs.url = "github:serokell/deploy-rs";
    deploy-rs.inputs.nixpkgs.follows = "nixpkgs";

    # secrets, shhhh
    agenix.url = "github:ryantm/agenix";
    agenix.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, deploy-rs, agenix }: {
    nixosConfigurations.kura = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [ 
        ./kura-configuration.nix
        agenix.nixosModules.default
      ];
    };
    nixosConfigurations.apple = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [ 
        # rpi stuff
        "${nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"
        {
          nixpkgs.config.allowUnsupportedSystem = true;
          nixpkgs.hostPlatform.system = "aarch64-linux";
          nixpkgs.buildPlatform.system = "x86_64-linux"; #If you build on x86 other wise changes this.

          sdImage.compressImage = false;
        }
        # actual system stuff
        ./apple-configuration.nix
        agenix.nixosModules.default
      ];
    };

    deploy.nodes = {

      kura = {
        hostname = "kura.joukamachi.net";

        # base profile for the system
        profiles.system = {
          sshUser = "deploy";
          sshOpts = [ "-i" "~/keys/id_deploy" ];
          user = "root";
          path = deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.kura;
        };

        # here we can list additonal service profiles
        # TODO: learn more about these and use them!
      };

      #apple = {
        #hostname = "apple.joukamachi.net";

        ## base profile for the system
        #profiles.system = {
          #sshUser = "deploy";
          #sshOpts = [ "-i" "~/keys/id_deploy" ];
          #user = "root";
          #path = deploy-rs.lib.aarch64-linux.activate.nixos self.nixosConfigurations.apple;
        #};
      #};
    };

    # This is highly advised, and will prevent many possible mistakes
    checks = builtins.mapAttrs (system: deployLib: deployLib.deployChecks self.deploy) deploy-rs.lib;
  };
}
