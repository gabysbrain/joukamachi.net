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
}

