# from https://github.com/mirosval/unbound-blocklist/tree/main
{ config, lib, pkgs, ... }:

{
  config = {
    networking.firewall.allowedUDPPorts = [ 53 ];
    networking.firewall.allowedTCPPorts = [ 53 ];

    services.unbound = {
      enable = true;
      blocklist.enable = true;
      settings = {
        server = {
          #verbosity = "5";
          interface = [ "0.0.0.0" ];
          access-control = [ "127.0.0.0/8 allow" "10.0.0.0/24 allow" ];
          tls-upstream = "yes";
          tls-cert-bundle = "/etc/pki/tls/certs/ca-bundle.crt";
          # my ISP seems to block these root DNS requests
          #root-hints = "${pkgs.dns-root-data}/root.key";
          #auto-trust-anchor-file = "/var/lib/unbound/root.key";
          domain-insecure = [ "joukamachi.net" ];
          #local-zone = ''"joukamachi.net." static'';
          #local-data = [
            #''"kura.joukamachi.net" IN A 10.0.0.50''
            #''"db.joukamachi.net" IN CNAME kura.joukamachi.net''
          #];
          root-hints = builtins.toString root-hints;
        };
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
