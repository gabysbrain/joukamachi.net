{ config, services, pkgs, ... }:

{
  # influxdb for timeseries data
  services.influxdb2 = {
    enable = true;
    #dataDir = "/db/influxdb";
    settings = {
      http-bind-address = "0.0.0.0:8086";
    };
  };

  networking.firewall.allowedTCPPorts = [ 8086 ];

  age.secrets.telegraf_token.file = ../secrets/influxdb_telegraf_token.age;
  services.telegraf = {
    enable = true;
    environmentFiles = [
      # influx pw
      config.age.secrets.telegraf_token.path
    ];
    extraConfig = {
      inputs = {
        system = {};
        mem = {};
        systemd_units = {};
        swap = {};
        diskio = {};
      };
      outputs = {
        influxdb_v2 = {
          urls = [ "http://localhost:8086" ];
          organization = "poodlehouse";
          bucket = "telegraf";
          token = "$INFLUX_TOKEN";
          #urls = [ config.services.influxdb.http.bind-address ];
        };
      };
    };
  };
}
