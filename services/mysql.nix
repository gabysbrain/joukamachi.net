{
  pkgs,
  ...
}:

{
  services.mysql = {
    enable = true;
    package = pkgs.mariadb;
    dataDir = "/db/mysql";
  };

  services.mysqlBackup = {
    enable = true;
    location = "/db/dumps/mysql";
    # FIXME: need to list all databases manually :(
    databases = [ ];
  };

}
