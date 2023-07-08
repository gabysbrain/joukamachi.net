{ config, services, pkgs, virtualization, ... }:

{
  imports = [
    ../pkgs/immich-service.nix
  ];

  virtualisation.docker.enable = true;

  services.immich = {
    enable = true;
    dataDir = /tmp/photos;
  };
}

