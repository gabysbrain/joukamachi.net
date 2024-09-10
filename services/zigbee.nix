# from https://github.com/mirosval/unbound-blocklist/tree/main
{ config, lib, pkgs, ... }:

{
  imports = [
    ../pkgs/zigbee2mqtt.nix
  ];

  services.mosquitto = {
    enable = true;
    persistence = false;
    listeners = [
      {
        acl = [ "pattern readwrite #" ];
        omitPasswordAuth = true;
        settings.allow_anonymous = true;
      }
    ];
  };

  services.z2m = {
    enable = true;
    arch = "aarch64";
    zigbeeController = "/dev/serial/by-id/usb-ITead_Sonoff_Zigbee_3.0_USB_Dongle_Plus_148d7bf450a4ed1198918a582981d5c7-if00-port0";
    #zigbeeController = "/dev/ttyUSB0";
    mqttUrl = "mqtt://mqtt.joukamachi.net:1883";
    settings = {
      mqtt = {
        base_topic = "zigbee2mqtt";
        #server = "mqtt://localhost:1883";
      };
    };
  };

  networking.firewall = {
    allowedTCPPorts = [ config.services.z2m.port 1883 ];
  };

  # send data to influx
  services.telegraf = {
    extraConfig = {
      inputs = {
        mqtt_consumer = {
          servers = [ "tcp://mqtt.joukamachi.net:1883" ];
          topics = [ "zigbee2mqtt/#" ];
          data_format = "json";
          #data_format = "influx";
          #topic_tag = "";
        };
      };
    };
  };
}
