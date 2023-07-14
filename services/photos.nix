{ config, services, pkgs, virtualization, ... }:

{
  imports = [
    ../pkgs/immich-service.nix
  ];

  #virtualisation.docker.enable = true;

  services.immich = {
    enable = true;
    port = 2283;
    dataDir = "/home-movies/";
    dbHostname = "db.joukamachi.net";
  };
  #users.users.immich = {
    #isSystemUser = true;
    #home = "/home-movies";
    #group = "immich";
  #};

  services.postgresql = {
    ensureDatabases = [ "immich" ];
    ensureUsers = [ {
      name = "immich";
    } ];
  };
}

