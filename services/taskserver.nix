{ config, services, pkgs, ... }:

{
  services.taskchampion-sync-server = {
    enable = true;
    openFirewall = true;
  };

  services.taskserver = {
    enable = true;
    fqdn = "taskserver.joukamachi.net";
    listenHost = "::";
    organisations.hadleyco.users = [ "tom" ];
    openFirewall = true;
  };
}

