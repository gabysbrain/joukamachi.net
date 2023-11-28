{ config, services, pkgs, virtualization, ... }:

{
  services.radarr = {
    enable = true;
    group = "jellyfin";
  };

  services.deluge = {
    enable = true;
    config = {
      max_upload_speed = "0";
      #share_ratio_limit = "0.0";
    };
    web.enable = true;
    group = "jellyfin";
  };

}
