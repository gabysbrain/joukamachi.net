# from https://github.com/mirosval/unbound-blocklist/tree/main
{ config, lib, pkgs, ... }:

let joukamachi-zone = pkgs.writeText "joukamachi.zone" (builtins.readFile ../joukamachi.zone);
    joukamachi-rev-zone = pkgs.writeText "joukamachi-rev.zone" (builtins.readFile ../joukamachi-rev.zone);
in
{
  config = {
    networking.firewall.allowedUDPPorts = [ 53 ];
    networking.firewall.allowedTCPPorts = [ 53 ];

    services.unbound = {
      enable = true;
      blocklist.enable = true;
      settings = {
        server = {
          verbosity = 2;
          interface = [ "0.0.0.0" ];
          access-control = [ "127.0.0.0/8 allow" "10.0.0.0/24 allow" ];
          tls-upstream = "yes";
          tls-cert-bundle = "/etc/pki/tls/certs/ca-bundle.crt";
          # my ISP seems to block these root DNS requests
          #root-hints = "${pkgs.dns-root-data}/root.key";
          #auto-trust-anchor-file = "/var/lib/unbound/root.key";
          domain-insecure = [ "joukamachi.net" ];
          private-domain = [ "joukamachi.net" ];
          unblock-lan-zones = "yes";
        };
        auth-zone = [
          { 
            name = "joukamachi.net";
            zonefile = builtins.toString joukamachi-zone;
          }
          { 

            name = "0.0.10.IN-ADDR.ARPA";
            zonefile = builtins.toString joukamachi-rev-zone;
          }
        ];
        forward-zone = [
          {
            name = ".";
            forward-addr = [ "8.8.8.8@853#dns.google" ];
            forward-tls-upstream = "yes";
          }
        ];
      };
    };
  };
}
