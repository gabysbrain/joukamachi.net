{ config, services, pkgs, virtualization, ... }:

{
  imports = [
    ../pkgs/immich-service.nix
  ];

  #virtualisation.docker.enable = true;

  age.secrets.immichdb-pw.file = ../secrets/immichdb-pw.age;
  services.my-immich = {
    enable = true;
    port = 2283;
    dataDir = "/home-movies/";
    dbHostname = "db.joukamachi.net";
    dbPasswordFile = config.age.secrets.immichdb-pw.path;
  };

  services.postgresql = {
    # FIXME: need to do CREATE EXTENSION cube and CREATE EXTENSION earthdistance on init
    # TODO: maybe use ensureDBOwnership for this db
    ensureDatabases = [ "immich" ];
    ensureUsers = [ {
      name = "immich";
    } ];
  };
}

