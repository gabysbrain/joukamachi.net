
{ lib, pkgs, ... }:

{
  services.nfs.server = {
    enable = true;

    exports = ''
      /exports/photoprism-cagla  10.0.0.53(rw,nohide,insecure,no_subtree_check)
      /exports/photoprism-tom    10.0.0.53(rw,nohide,insecure,no_subtree_check)
      /home-movies               10.0.0.53(ro,nohide,insecure,no_subtree_check)
    '';
  };

  networking.firewall.allowedTCPPorts = [ 2049 ];
}

