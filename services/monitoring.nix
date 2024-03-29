{ config, services, pkgs, ... }:

let networkGear = [ "10.0.0.1" "10.0.0.2" "10.0.0.3" ];
in
{
  imports = [
    ../pkgs/restic-exporter-service.nix
  ];

  services.grafana = {
    enable = true;
    settings.server.http_addr = "127.0.0.1";
    settings.server.http_port = 2342;
  };

  # influxdb for timeseries data
  services.influxdb = {
    enable = true;
    dataDir = "/db/influxdb";
    #settings = {
      #http-bind-address = "0.0.0.0:8088";
    #};
  };

  networking.firewall.allowedTCPPorts = [ 8086 ];

  services.telegraf = {
    extraConfig = {
      inputs = {
        prometheus = {
          urls = [
            "http://localhost:${toString config.services.restic-exporter.port}"
          ];
        };

        snmp = {
          agents = networkGear;
          version = 2;
          community = "public";

          field = [
            { oid =  "SNMPv2-MIB::sysName.0"; name = "host"; is_tag = true; }
            { oid = "DISMAN-EVENT-MIB::sysUpTimeInstance"; name = "uptime"; }
          ];
          table = [
            # IF-MIB::ifTable contains counters on input and output traffic as well as errors and discards.
            { oid = "IF-MIB::ifTable"; name = "interface"; inherit_tags = [ "host" ]; field = [
                # Interface tag - used to identify interface in metrics database
                { oid = "IF-MIB::ifDescr"; name = "ifDescr"; is_tag = true; }
              ];
            }

            # IF-MIB::ifXTable contains newer High Capacity (HC) counters that do not overflow as fast for a few of the ifTable counters
            { oid = "IF-MIB::ifXTable"; name = "interface"; inherit_tags = [ "host" ]; field = [
                # Interface tag - used to identify interface in metrics database
                { oid = "IF-MIB::ifDescr"; name = "ifDescr"; is_tag = true; }
              ];
            }

            # EtherLike-MIB::dot3StatsTable contains detailed ethernet-level information about what kind of errors have been logged on an interface (such as FCS error, frame too long, etc)
            { oid = "EtherLike-MIB::dot3StatsTable"; name = "interface"; inherit_tags = [ "host" ]; field = [
                # Interface tag - used to identify interface in metrics database
                { oid = "IF-MIB::ifDescr"; name = "ifDescr"; is_tag = true; }
              ];
            }
          ];
        };
      };
    };
  };
  # need the snmp stuff for snmp translating
  systemd.services.telegraf.path = [ pkgs.net-snmp ];

  age.secrets.restic = {
    file = ../secrets/restic.age;
    owner = "restic";
    group = "restic";
  };

  services.restic-exporter = {
    enable = true;
    repoUrl = config.services.restic.server.dataDir;
    repoPasswordFile = config.age.secrets.restic.path;

    refreshInterval = 3 * 60 * 60; # 3 hours
  };
}
