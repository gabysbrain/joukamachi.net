{ config, pkgs, services, ...}: 

{
  services.grocy = {
    enable = true;
    hostName = "grocy.joukamachi.net";
    #nginx.enableSSL = false;
    nginx.enableSSL = true;
    dataDir = "/var/lib/grocy";
    settings.currency = "EUR";
  };
}

