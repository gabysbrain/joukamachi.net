# from https://github.com/mirosval/unbound-blocklist/tree/main
{ config, lib, pkgs, ... }:

let root-hints = pkgs.writeText "root.hints" (builtins.readFile ../named.root);
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
          #verbosity = "5";
          interface = [ "0.0.0.0" ];
          access-control = [ "127.0.0.0/8 allow" "10.0.0.0/24 allow" ];
          tls-upstream = "yes";
          tls-cert-bundle = "/etc/pki/tls/certs/ca-bundle.crt";
          domain-insecure = [ "joukamachi.net" ];
          root-hints = "${root-hints}";
          #local-zone = ''"joukamachi.net." static'';
          #local-data = [
            #''"kura.joukamachi.net" IN A 10.0.0.50''
            #''"db.joukamachi.net" IN CNAME kura.joukamachi.net''
          #];
        };
        forward-zone = [
          {
            name = ".";
            #forward-addr = [ "10.0.0.1" ];
            #forward-addr = [ "1.1.1.1" "8.8.8.8" ];
            #forward-addr = [ "10.0.0.1" "8.8.8.8" ];
            forward-addr = [ "8.8.8.8@853#dns.google" ];
            forward-tls-upstream = "yes";
          }
        ];
      };
    };
  };
}