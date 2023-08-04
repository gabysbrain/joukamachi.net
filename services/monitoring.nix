{ config, services, pkgs, ... }:

{
  imports = [
    ../pkgs/restic-exporter-service.nix
  ];

  services.grafana = {
    enable = true;
    settings.server.http_addr = "127.0.0.1";
    settings.server.http_port = 2342;
  };

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

  services.prometheus = {
    enable = true;

    scrapeConfigs = [
      { 
        job_name = "node";
        static_configs = [{
          # list all nodes here
          # FIXME: one day do ${toString config.services.prometheus.exporters.node.port}
          targets = [ "kura.joukamachi.net:9002" ];
        }];
      }

      # restic server
      { 
        job_name = "restic_exporter";
        static_configs = [{
          targets = [ "localhost:${toString config.services.restic-exporter.port}" ];
        }];
      }

      # restic server
      { 
        job_name = "restic_rest_server";
        scrape_interval = "5s";
        scheme = "https";
        static_configs = [{
          targets = [ "backup.joukamachi.net" ];
        }];
      }

      # SNMP
      {
        job_name = "snmp";
        metrics_path = "/snmp";
        params = { module = [ "if_mib" ]; };
        relabel_configs = [
          { source_labels = ["__address__"];    target_label = "__param_target"; }
          { source_labels = ["__param_target"]; target_label = "instance"; }
          { source_labels = []; target_label = "__address__"; replacement = "localhost:9116"; }
        ];
        static_configs = [{
          targets = [ "router.lan" "main-switch.joukamachi.net" "lr-switch.joukamachi.net" ];
        }];
      }
    ];

    # extra exporters
    exporters = {
      snmp = {
        enable = true;
        configuration = null;
        configurationPath = "${pkgs.prometheus-snmp-exporter.src}/snmp.yml";
      };
    };
  };

  # needed for exporter
  networking.firewall.allowedTCPPorts = [ 9002 ];
}
