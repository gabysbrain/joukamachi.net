{ config, services, pkgs, ... }:

{
  services.jellyfin.enable = true;

  # hardware transcoding
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      vaapiVdpau
      libvdpau-va-gl

      rocmPackages.clr
    ];
  };
}

