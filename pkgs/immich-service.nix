{config, pkgs, lib, ...}:
 
 let
   cfg = config.services.immich;
   immichVersion = "v1.88.2";
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

      typesenseApiKey = mkOption {
        type = types.str;
        default = "changeme";
        description = ''
          secret key on the typesense api server
        '';
      };
    };
  };

  config = mkIf cfg.enable {
    virtualisation.oci-containers.containers = {
      "immich-server" = {
        image = "ghcr.io/immich-app/immich-server:${immichVersion}";
        cmd = [ "start.sh" "immich" ];
        volumes = [ 
          "${cfg.dataDir}:/usr/src/app/upload"
          "/run/agenix:/run/agenix"
        ];
        environment = {
          TYPESENSE_API_KEY = cfg.typesenseApiKey;
          DB_HOSTNAME = cfg.dbHostname;
          DB_DATABASE_NAME = cfg.dbDatabase;
          DB_USERNAME = cfg.dbUsername;
          DB_PASSWORD_FILE = cfg.dbPasswordFile;
          DB_PORT = toString cfg.dbPort;
          REDIS_HOSTNAME = "redis";
        };
        #dependsOn = [ "redis" "typesense" ];
        autoStart = true;
        extraOptions = [ "--pod=immich" ];
      };
      "immich-microservices" = {
        image = "ghcr.io/immich-app/immich-server:${immichVersion}";
        cmd = [ "start.sh" "microservices" ];
        volumes = [ 
          "${cfg.dataDir}:/usr/src/app/upload" 
          "/run/agenix:/run/agenix"
        ];
        environment = {
          TYPESENSE_API_KEY = cfg.typesenseApiKey;
          DB_HOSTNAME = cfg.dbHostname;
          DB_DATABASE_NAME = cfg.dbDatabase;
          DB_USERNAME = cfg.dbUsername;
          DB_PASSWORD_FILE = cfg.dbPasswordFile;
          DB_PORT = toString cfg.dbPort;
          REDIS_HOSTNAME = "redis";
        };
        #dependsOn = [ "redis" "typesense" ];
        autoStart = true;
        extraOptions = [ "--pod=immich" ];
      };
      "immich-machine-learning" = {
        image = "ghcr.io/immich-app/immich-machine-learning:${immichVersion}";
        volumes = [ "model-cache:/usr/src/app/upload" ];
        autoStart = true;
        extraOptions = [ "--pod=immich" ];
      };
      "typesense" = {
        image = "typesense/typesense:0.24.1@sha256:9bcff2b829f12074426ca044b56160ca9d777a0c488303469143dd9f8259d4dd";
        environment = {
          TYPESENSE_API_KEY = cfg.typesenseApiKey;
          TYPESENSE_DATA_DIR = "/data";
        };
        log-driver = "none";
        volumes = [ "tsdata:/data" ];
        autoStart = true;
        extraOptions = [ "--pod=immich" ];
      };
      "redis" = {
        image = "redis:6.2-alpine@sha256:70a7a5b641117670beae0d80658430853896b5ef269ccf00d1827427e3263fa3";
        autoStart = true;
        extraOptions = [ "--pod=immich" ];
      };
    };

    systemd.services.podman-immich-server.serviceConfig.Type = lib.mkForce "exec";
    systemd.services.podman-immich-microservices.serviceConfig.Type = lib.mkForce "exec";
    systemd.services.podman-immich-machine-learning.serviceConfig.Type = lib.mkForce "exec";

    systemd.services.podman-create-pod-immich = {
      serviceConfig.Type = "oneshot";
      wantedBy = [ 
        "podman-immich-server.service" 
        "podman-immich-microservices.service" 
        "podman-immich-machinelearning.service" 
        "podman-typesense.service" 
        "podman-redis.service" 
      ];

      script = ''
        ${pkgs.podman}/bin/podman pod create --name immich --replace -p '${toString cfg.port}:3001'
      '';
    };
  };
}

