{ config, services, pkgs, ... }:

{
  services.taskserver = {
    enable = true;
    fqdn = "taskserver.joukamachi.net";
    listenHost = "::";
    organisations.hadleyco.users = [ "tom" ];
    openFirewall = true;
  };
}

