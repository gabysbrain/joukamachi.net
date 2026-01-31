{
  lib,
  config,
  services,
  pkgs,
  ...
}:

{
  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_16;
    enableTCPIP = true;
    dataDir = "/db/postgres";
    authentication = lib.mkForce ''
      local all all trust
      host  all all 10.0.0.0/24 md5
      host  all all 10.88.0.0/16 md5
      host  all all 172.0.0.0/8 md5
    '';
  };

  networking.firewall.allowedTCPPorts = [ 5432 ];

  services.postgresqlBackup = {
    enable = true;
    backupAll = true;
    location = "/db/dumps/pg";
  };

}
