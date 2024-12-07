{config, pkgs, lib, ...}:
 
 let
   cfg = config.services.immich;
   immichVersion = "v1.121.0";
 in
 
 with lib;
 
{
  options = {
    services.immich = {
      enable = mkOption {
        default = false;
        type = with types; bool;
        description = ''
         Start immich
        '';
      };

      port = mkOption {
        type = types.port;
        default = 8080;
        description = ''
         Port the listener should listen on
        '';
      };

      dataDir = mkOption {
        type = types.str;
        description = ''
          root location of image storage directory
        '';
      };

      dbHostname = mkOption {
        type = types.str;
        default = "localhost";
        description = ''
          hostname of the database server
        '';
      };

      dbPort = mkOption {
        type = types.int;
        default = 5432;
        description = ''
          port for the database server
        '';
      };

      dbUsername = mkOption {
        type = types.str;
        default = "immich";
        description = ''
          username for the database connection
        '';
      };

      dbPasswordFile = mkOption {
        type = types.str;
        description = ''
          location of the file with password for the database user
        '';
      };

      dbDatabase = mkOption {
        type = types.str;
        default = "immich";
        description = ''
          name of the database
        '';
      };
    };
  };

  config = mkIf cfg.enable {
    virtualisation.oci-containers.containers = {
      "immich-server" = {
        image = "ghcr.io/immich-app/immich-server:${immichVersion}";
        #cmd = [ "start.sh" "immich" ];
        volumes = [ 
          "${cfg.dataDir}:/usr/src/app/upload"
          "/run/agenix:/run/agenix"
        ];
        environment = {
          DB_HOSTNAME = cfg.dbHostname;
          DB_DATABASE_NAME = cfg.dbDatabase;
          DB_USERNAME = cfg.dbUsername;
          DB_PASSWORD_FILE = cfg.dbPasswordFile;
          DB_PORT = toString cfg.dbPort;
          REDIS_HOSTNAME = "redis.joukamachi.net";
          REDIS_PORT = "6380";
        };
        autoStart = true;
        extraOptions = [ "--pod=immich" ];
      };
      "immich-machine-learning" = {
        image = "ghcr.io/immich-app/immich-machine-learning:${immichVersion}";
        volumes = [ "model-cache:/usr/src/app/upload" ];
        autoStart = true;
        extraOptions = [ "--pod=immich" ];
      };
    };

    systemd.services.podman-immich-server.serviceConfig.Type = lib.mkForce "exec";
    systemd.services.podman-immich-machine-learning.serviceConfig.Type = lib.mkForce "exec";

    systemd.services.podman-create-pod-immich = {
      serviceConfig.Type = "oneshot";
      wantedBy = [ 
        "podman-immich-server.service" 
        "podman-immich-machinelearning.service" 
      ];

      script = ''
        ${pkgs.podman}/bin/podman pod create --name immich --replace -p '${toString cfg.port}:2283'
      '';
    };
  };
}

