{config, pkgs, lib, ...}:
 
 let
   cfg = config.services.z2m;
   z2mVersion = "1.39.0";

   format = pkgs.formats.yaml { };
   configFile = format.generate "zigbee2mqtt.yaml" cfg.settings;
 in
 
 with lib;
 
{
  options = {
    services.z2m = {
      enable = mkOption {
        default = false;
        type = with types; bool;
        description = ''
         Start zigbee2mqtt
        '';
      };

      port = mkOption {
        type = types.port;
        default = 8080;
        description = ''
         Port the listener should listen on
        '';
      };

      arch = mkOption {
        type = types.str;
        description = ''
          architecture the image is running on (e.g. aarch64)
        '';
      };

      settings = mkOption {
        type = format.type;
        default = { };
      };

      dataDir = mkOption {
        type = types.str;
        default = "/var/lib/zigbee2mqtt";
        description = ''
          root location of data storage directory
        '';
      };

      zigbeeController = mkOption {
        type = types.str;
        description = ''
          zigbee controller device (starts with /dev)
        '';
      };

      mqttUrl = mkOption {
        type = types.str;
        default = "mqtt://localhost:1883";
        description = ''
          URL of the mqtt server (including port)
        '';
      };
    };
  };

  config = mkIf cfg.enable {

    # preset config settings
    services.z2m.settings = {
      permit_join = mkDefault false;
      mqtt = {
        base_topic = mkDefault "zigbee2mqtt";
        server = cfg.mqttUrl;
      };
      serial.port = mkDefault "/dev/ttyUSB0";
      #serial.port = cfg.zigbeeController;
      data_path = "/app/data_dir";
      devices = mkDefault "devices.yaml";
      groups = mkDefault "groups.yaml";
      external_converters = [];
      frontend.port = 8080;
      homeassistant = false;
      advanced.log_output = [ "console" ];
    };

    virtualisation.oci-containers.containers = {
      "zigbee2mqtt" = {
        image = "docker.io/koenkk/zigbee2mqtt:${z2mVersion}";
        volumes = [ 
          "${cfg.dataDir}:/app/data"
          "/run/udev:/run/udev:ro"
        ];
        environment = {
          TZ = "Europe/Vienna";
        };
        autoStart = true;
        #user = "${toString config.ids.uids.zigbee2mqtt}";
        ports = [ "${toString cfg.port}:8080" ];
        extraOptions = [ 
          #"--gidmap=20:27"
          "--device=${cfg.zigbeeController}:/dev/ttyUSB0"
        ];
      };
    };

    systemd.services.podman-zigbee2mqtt = {
      preStart = ''
        cp --no-preserve=mode ${configFile} "${cfg.dataDir}/configuration.yaml"
      '';
    };
  };
}

