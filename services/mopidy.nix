# from https://github.com/mirosval/unbound-blocklist/tree/main
{
  config,
  lib,
  pkgs,
  ...
}:

{
  networking.firewall.allowedTCPPorts = [
    6600
    6680
  ];

  age.secrets.mopidy-jellyfin-conf = {
    file = ../secrets/mopidy-jellyfin-conf.age;
    owner = "mopidy";
  };
  services.mopidy = {
    enable = true;
    extensionPackages = [
      pkgs.mopidy-iris
      pkgs.mopidy-jellyfin
      pkgs.mopidy-mpd
      pkgs.mopidy-somafm
      pkgs.mopidy-tidal
    ];
    configuration = ''
      [http]
      enabled = true
      hostname = localhost
      port = 6680
      allowed_origins = ttw.music.joukamachi.net
      default_app = iris

      [mpd]
      enabled = true
      hostname = 0.0.0.0

      [somafm]
      encoding = aac
      quality = highest


      [audio]
      output = audioresample ! audioconvert ! audio/x-raw,rate=48000,channels=2,format=S16LE ! wavenc ! filesink location=/run/snapserver/pipewire
    '';
    extraConfigFiles = [ config.age.secrets.mopidy-jellyfin-conf.path ];
  };
}
