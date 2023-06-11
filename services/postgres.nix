{ config, services, pkgs, ... }:

{
  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_15;
    dataDir = "/db/postgres";
  };

  services.postgresqlBackup = {
    enable = true;
    backupAll = true;
    location = "/db/dumps/pg";
  };

}

