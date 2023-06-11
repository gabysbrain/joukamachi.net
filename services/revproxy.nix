{ config, services, pkgs, ... }:

{
  networking.firewall.allowedTCPPorts = [ 80 443 ];

  # virtual host to backup url
  services.nginx = {
    enable = true;
    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;

    virtualHosts."media.joukamachi.net" = {
      forceSSL = true;
      enableACME = true;
      acmeRoot = null;
      locations."/" = {
        proxyPass = "http://localhost:8096";
      };
    };

    virtualHosts."backup.joukamachi.net" = {
      forceSSL = true;
      enableACME = true;
      acmeRoot = null;
      locations."/" = {
        proxyPass = "http://localhost:8000";
      };
      extraConfig = ''
        client_max_body_size 32M;
      '';
    };

  };

  age.secrets.digitalocean.file = ../secrets/digitalocean.age;
  security.acme = {
    acceptTerms = true;
    defaults = {
      email = "torsneyt@gmail.com";
      dnsProvider = "digitalocean";
      credentialsFile = config.age.secrets.digitalocean.path;
    };
    certs = {
      "backup.joukamachi.net".email = "torsneyt@gmail.com";
    };
  };

}
