{ config, services, pkgs, ... }:

{
  services.redis.servers = {
    "scratch" = {
      enable = true;
      port = 6379;
    };
    "immich" = {
      enable = true;
      port = 6380;
    };
  };

  services.telegraf = {
    extraConfig = {
      inputs = {
        servers = [ 
          "tcp://redis.joukamachi.net:6379"
          "tcp://redis.joukamachi.net:6380"
        ];
      };
    };
  };
}

