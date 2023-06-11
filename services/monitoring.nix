{ config, services, pkgs, ... }:

{
  services.grafana = {
    enable = true;
    settings.server.http_addr = "127.0.0.1";
    settings.server.http_port = 2342;
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
      { job_name = "restic_rest_server";
        scrape_interval = "5s";
        scheme = "https";
        static_configs = [{
          targets = [ "backup.joukamachi.net" ];
        }];
      }
    ];
  };
}
