{ config, services, pkgs, ... }:

let servers = [
  { name = "scratch"; port = 6379; }
  { name = "immich"; port = 6380; }
];
in
{
  services.redis.servers = builtins.listToAttrs (map (s: { name = s.name; value = { port = s.port; enable = true; openFirewall = true; };}) servers);

  services.telegraf = {
    extraConfig = {
      inputs = {
        servers = map (s: "tcp://redis.joukamachi.net:" + toString s.port) servers;
      };
    };
  };
}

