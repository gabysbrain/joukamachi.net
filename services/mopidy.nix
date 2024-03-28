# from https://github.com/mirosval/unbound-blocklist/tree/main
{ config, lib, pkgs, ... }:

{
  networking.firewall.allowedTCPPorts = [ 6680 ];

  services.mopidy = {
    enable = true;
    extensionPackages = [
      pkgs.mopidy-iris
      pkgs.mopidy-tidal
    ];
    configuration = ''
    [http]
    enabled = true
    hostname = localhost
    port = 6680
    allowed_origins = ttw.music.joukamachi.net
    default_app = iris
    '';
  };
}
