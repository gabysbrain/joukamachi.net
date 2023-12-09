{ config, services, pkgs, virtualization, ... }:

{
  imports = [
    ../pkgs/immich-service.nix
  ];

  #virtualisation.docker.enable = true;

  age.secrets.immichdb-pw.file = ../secrets/immichdb-pw.age;
  services.immich = {
    enable = true;
    port = 2283;
    dataDir = "/home-movies/";
    dbHostname = "db.joukamachi.net";
    dbPasswordFile = config.age.secrets.immichdb-pw.path;
  };

  services.postgresql = {
    # FIXME: need to do CREATE EXTENSION cube and CREATE EXTENSION earthdistance on init
    ensureDatabases = [ "immich" ];
    ensureUsers = [ {
      name = "immich";
    } ];
  };
}

