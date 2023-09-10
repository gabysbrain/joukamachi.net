{ config, services, pkgs, ... }:

let networkGear = [ "10.0.0.1" "10.0.0.2" "10.0.0.3" ];
in
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
        # these should be set up for every system
        system = {};
        cpu = {};
        mem = {};
        systemd_units = {};
        swap = {};
        kernel = {};
        processes = {};
        net = {};
        netstat = {};
        interrupts = {};
        linux_sysctl_fs = {};
        disk = {
          ignore_fs = [ "tmpfs" "devtmpfs" ];
        };
        diskio = {};
        temp = {};

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
  # need the snmp stuff for snmp translating
  systemd.services.telegraf.path = [ pkgs.net-snmp ];
}
