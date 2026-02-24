{
  config,
  services,
  pkgs,
  ...
}:

let
  redisConfig = s: {
    name = s.name;
    value = {
      port = s.port;
      enable = true;
      openFirewall = true;
      bind = null;
      settings = {
        protected-mode = "no";
        maxmemory = "256mb";
      };
    };
  };
  servers = [
    #{ name = "scratch"; port = 6379; }
    {
      name = "immich";
      port = 6380;
    }
  ];
in
{
  services.redis.vmOverCommit = true;
  services.redis.servers = builtins.listToAttrs (map redisConfig servers);

  services.telegraf = {
    extraConfig = {
      inputs = {
        redis = {
          servers = map (s: "tcp://redis.joukamachi.net:" + toString s.port) servers;
        };
      };
    };
  };
}
