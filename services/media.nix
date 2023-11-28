{ config, services, pkgs, virtualization, ... }:

{
  users.groups.media = {};

  services.radarr = {
    enable = true;
    group = "media";
  };

  services.deluge = {
    enable = true;
    config = {
      max_upload_speed = "0";
      #share_ratio_limit = "0.0";
    };
    web.enable = true;
    group = "media";
  };

}
