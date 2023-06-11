{ config, services, pkgs, ... }:

{
  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_15;
    enableTCPIP = true;
    dataDir = "/db/postgres";
  };

  services.postgresqlBackup = {
    enable = true;
    backupAll = true;
    location = "/db/dumps/pg";
  };

}

