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
    authentication = pkgs.lib.mkOverride 10 ''
      local all all trust
      host  sameuser all 127.0.0.1/32 scram-sha-256
      host  sameuser all 10.0.0.0/24 scram-sha-256
    '';

    # TODO: ideally in auth.nix but that's on another host
    ensureDatabases = [ "authelia" ];
    ensureUsers = [
      {
        name = "authelia";
        ensureDBOwnership = true;
        ensureClauses = {
          login = true;
        };
      }
    ];
  };

  networking.firewall.allowedTCPPorts = [ 5432 ];

  services.postgresqlBackup = {
    enable = true;
    backupAll = true;
    location = "/db/dumps/pg";
  };

}
