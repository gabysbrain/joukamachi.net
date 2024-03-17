{ config, services, pkgs, ... }:

{
  services.telegraf = {
    enable = true;
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
      };
      outputs = {
        influxdb = {
          urls = [ "http://db.joukamachi.net:8086" ];
          database = "telegraf";
        };
      };
    };
  };

  services.promtail = {
    enable = true;

    configuration = {
      server = {
        http_listen_port = 0;
        grpc_listen_port = 0;
      };

      positions = {
        filename = "/tmp/positions.yaml";
      };

      clients = [{
        url = "http://db.joukamachi.net:3030/loki/api/v1/push";
      }];

      scrape_configs = [{
        job_name = "journal";
        journal = {
          max_age = "12h";
          labels = {
            job = "systemd-journal";
            host = config.networking.hostName;
          };
        };

        relabel_configs = [{
          source_labels = [ "__journal__systemd_unit" ];
          target_label = "unit";
        }];
      }];
    };
  };

}
