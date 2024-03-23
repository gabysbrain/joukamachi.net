# from https://github.com/mirosval/unbound-blocklist/tree/main
{ config, lib, pkgs, ... }:

let domain = "joukamachi.net";
    hosts = rec {
      "router" = "10.0.0.1";
      "main-switch" = "10.0.0.2";
      "lr-switch" = "10.0.0.3";
      "printer" = "10.0.0.30";
      "kura" = "10.0.0.50";
      "apple" = "10.0.0.51";
      "cherry" = "10.0.0.60";
      "katana" = "10.0.0.90";

      "backup" = hosts.kura;
      "code" = hosts.kura;
      "db" = hosts.kura;
      "media" = hosts.kura;
      "monitor" = hosts.kura;
      "photos" = hosts.kura;
      "taskserver" = hosts.kura;

      "ns" = hosts.apple;
    };
in
{
  networking.firewall.allowedUDPPorts = [ 53 ];
  networking.firewall.allowedTCPPorts = [ 53 5380 ];

  services.blocky = {
    enable = true;
    settings = {
      ports = {
        dns = 53;
        http = 5380;
      };
      log.level = "warn";
      upstreams.groups = {
        default = [
          "https://dns.google/dns-query"
          #"https://dns.google/resolve?"
        ];
      };
      bootstrapDns = {
        upstream = "https://dns.google/dns-query";
        #upstream = "https://dns.google/resolve?";
        ips = [ "8.8.8.8" "8.8.4.4" ];
      };
      blocking = {
        blackLists = {
          ads = ["https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts"];
        };
        clientGroupsBlock = {
          default = [ "ads" ];
        };
      };
      customDNS = {
        mapping = lib.attrsets.mapAttrs' 
          (hostname: ip: lib.attrsets.nameValuePair (hostname + "." + domain) ip) 
          hosts // {
            "." = "10.0.0.51";
          };
      };
      # monitoring (only prometheus is available)
      prometheus = {
        enable = true;
        path = "/metrics";
      };
    };
  };

  # monitoring
  services.telegraf = {
    extraConfig = {
      inputs = {
        prometheus = {
          urls = [
            "http://ns.joukamachi.net:${toString config.services.blocky.settings.ports.http}"
          ];
        };
      };
    };
  };
}
