# from https://github.com/mirosval/unbound-blocklist/tree/main
{
  config,
  ...
}:

{
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

  services.zigbee2mqtt = {
    enable = true;
    settings = {
      permit_join = false;
      data_path = "/var/lib/zigbee2mqtt";
      mqtt = {
        base_topic = "zigbee2mqtt";
        server = "mqtt://mqtt.joukamachi.net:1883";
      };
      serial.port = "/dev/serial/by-id/usb-ITead_Sonoff_Zigbee_3.0_USB_Dongle_Plus_148d7bf450a4ed1198918a582981d5c7-if00-port0";
      frontend.port = 8080;
      homeassistant.enabled = config.services.home-assistant.enable;
    };
  };

  networking.firewall = {
    allowedTCPPorts = [
      config.services.zigbee2mqtt.settings.frontend.port
      1883
    ];
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
