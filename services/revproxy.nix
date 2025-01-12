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

      locations."/socket" = {
        proxyPass = "http://localhost:8096";
        # needed for websockets
          #proxy_set_header Upgrade ''$http_upgrade;
          #proxy_set_header Connection "upgrade";
          #proxy_set_header Host $host;
          #proxy_set_header X-Real-IP ''$remote_addr;
          #proxy_set_header X-Forwarded-For ''$proxy_add_x_forwarded_for;
          #proxy_set_header X-Forwarded-Proto ''$scheme;
          #proxy_set_header X-Forwarded-Protocol ''$scheme;
          #proxy_set_header X-Forwarded-Host ''$http_host;
        extraConfig = ''
          proxy_set_header Upgrade ''$http_upgrade;
          proxy_set_header Connection ''$http_connection;
        '';
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
        # needed for websockets
        extraConfig = ''
          proxy_set_header Upgrade ''$http_upgrade;
          proxy_set_header Connection ''$http_connection;
        '';
      };
    };

    virtualHosts."cachix.joukamachi.net" = {
      enableACME = true;
      forceSSL = true;
      acmeRoot = null;
      locations."/" = {
        proxyPass = "http://localhost:18080/";
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
        proxyPass = "http://[::1]:${toString config.services.immich.port}";
        proxyWebsockets = true;
      };
    };

    virtualHosts."snapserver.joukamachi.net" = {
      enableACME = true;
      forceSSL = true;
      acmeRoot = null;
      locations."/" = {
        proxyPass = "http://localhost:1780/";
        # needed for websockets
        extraConfig = ''
          proxy_set_header Upgrade ''$http_upgrade;
          proxy_set_header Connection ''$http_connection;
        '';
      };
    };

    virtualHosts."ttw.music.joukamachi.net" = {
      enableACME = true;
      forceSSL = true;
      acmeRoot = null;
      locations."/" = {
        proxyPass = "http://localhost:6680/";
        # needed for websockets
        extraConfig = ''
          proxy_set_header Upgrade ''$http_upgrade;
          proxy_set_header Connection ''$http_connection;
        '';
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
  };

}
