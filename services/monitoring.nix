{ config, services, pkgs, ... }:

{
  services.grafana = {
    enable = true;
    settings.server.http_addr = "127.0.0.1";
    settings.server.http_port = 2342;
  };

  age.secrets.restic-exporter-env.file = ../secrets/restic-exporter-env.age;
  services.restic-exporter = {
    enable = true;

    # Optional configuration
    port = "8567";
    address = "127.0.0.1";
    user = "restic-exporter";
    group = "restic-exporter";
    environmentFile = config.age.secrets.restic-exporter-env.path;
  };

  services.prometheus = {
    enable = true;

    scrapeConfigs = [
      { job_name = "node";
        static_configs = [{
          # list all nodes here
          # FIXME: one day do ${toString config.services.prometheus.exporters.node.port}
          targets = [ "kura.lan:9002" ];
        }];
      }

      # restic server
      { job_name = "restic_exporter";
        metrics_path = "/probe";
        relabel_configs = [
          { source_labels = [ "__address__" ];
            target_label = "__param_target";
          }
          { source_labels = [ "__param_target" ];
            target_label = "target";
          }
          { replacement = "localhost:${toString config.services.restic-exporter.port}";
            target_label = "__address__";
          }
        ];
        scrape_interval = "1h";
        scrape_timeout = "19m";
        static_configs = [{
          targets = [ "katana" "mbp" "zenbook" "kura" ];
        }];
      }

      # restic server
      { job_name = "restic_rest_server";
        scrape_interval = "5s";
        scheme = "https";
        static_configs = [{
          targets = [ "backup.joukamachi.net" ];
        }];
      }
    ];
  };

  # needed for exporter
  networking.firewall.allowedTCPPorts = [ 9002 ];
}
