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

}
