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
          interface = [ "0.0.0.0" ];
          access-control = [ "10.0.0.0/8 allow" ];
        };
        forward-zone = [
          {
            name = ".";
            forward-addr = [ "10.0.0.1" "8.8.8.8" ];
            forward-tls-upstream = "yes";
          }
        ];
      };
    };
  };
}
