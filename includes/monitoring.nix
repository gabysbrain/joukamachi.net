{
  config,
  ...
}:

{
  services.telegraf = {
    enable = true;
    extraConfig = {
      agent = {
        metric_batch_size = 100;
      };
      inputs = {
        # these should be set up for every system
        system = { };
        cpu = { };
        mem = { };
        systemd_units = { };
        swap = { };
        kernel = { };
        processes = { };
        net = { };
        netstat = { };
        interrupts = { };
        linux_sysctl_fs = { };
        disk = {
          ignore_fs = [
            "tmpfs"
            "devtmpfs"
          ];
        };
        diskio = { };
        temp = { };
      };
      outputs = {
        influxdb = {
          urls = [ "http://db.joukamachi.net:8086" ];
          database = "telegraf";
        };
      };
    };
  };

  # for systemd/journald logs
  services.fluent-bit = {
    enable = true;

    settings = {
      pipeline = {
        inputs = [
          {
            name = "systemd";
          }
        ];
        outputs = [
          {
            name = "loki";
            host = "db.joukamachi.net";
            port = 3100;
          }
        ];
      };
    };
  };

}
