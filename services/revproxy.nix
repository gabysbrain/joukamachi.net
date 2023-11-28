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
    clientMaxBodySize = "2g";

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

    virtualHosts."monitor.joukamachi.net" = {
      forceSSL = true;
      enableACME = true;
      acmeRoot = null;
      locations."/" = {
        proxyPass = "http://localhost:2342";
      };
    };

    virtualHosts."code.joukamachi.net" = {
      enableACME = true;
      forceSSL = true;
      acmeRoot = null;
      locations."/" = {
        proxyPass = "http://localhost:3001/";
      };
    };

    virtualHosts."photos.joukamachi.net" = {
      enableACME = true;
      forceSSL = true;
      acmeRoot = null;
      locations."/" = {
        proxyPass = "http://localhost:2283/";
      };
    };

    virtualHosts."radarr.joukamachi.net" = {
      enableACME = true;
      forceSSL = true;
      acmeRoot = null;
      locations."/" = {
        proxyPass = "http://localhost:7878/";
      };
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
