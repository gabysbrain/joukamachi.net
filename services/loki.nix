{
  config,
  ...
}:

{
  services.loki = {
    enable = true;
    dataDir = "/db/loki";

    configuration = {
      server.http_listen_port = 3100;
      auth_enabled = false;

      common = {
        ring = {
          kvstore.store = "inmemory";
        };
        instance_addr = "127.0.0.1";
        replication_factor = 1;
        path_prefix = "/tmp/loki";
      };

      schema_config = {
        configs = [
          {
            from = "2020-05-15";
            store = "tsdb";
            object_store = "filesystem";
            schema = "v13";
            index = {
              prefix = "index_";
              period = "24h";
            };
          }
        ];
      };

      storage_config.filesystem.directory = "/tmp/loki/chunks";

      common.instance_interface_names = builtins.attrNames config.networking.interfaces;
    };
  };

  # loki listening port
  networking.firewall.allowedTCPPorts = [
    config.services.loki.configuration.server.http_listen_port
  ];
}
