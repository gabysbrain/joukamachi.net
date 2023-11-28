{ config, services, pkgs, virtualization, ... }:

{
  services.radarr = {
    enable = true;
    group = "jellyfin";
  };

}
