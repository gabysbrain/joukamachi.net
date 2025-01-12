{ config, services, pkgs, virtualization, ... }:

{
  age.secrets.immich-secrets.file = ../secrets/immich-secrets.age;
  services.immich = {
    enable = true;
    port = 2283;
    secretsFile = "${config.age.secrets.immich-secrets.path}";
    mediaLocation = "/home-movies/";
    database.host = "db.joukamachi.net";
    redis.enable = false;
    redis.host = "redis.joukamachi.net";
    redis.port = 6380;
  };

  # faster video transcoding
  users.users.immich.extraGroups = [ "video" "render" ];
}

