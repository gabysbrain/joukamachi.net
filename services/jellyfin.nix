{ config, services, pkgs, ... }:

{
  users.groups.media = {};

  services.jellyfin = {
    enable = true;
    group = "media";
  };

  # hardware transcoding
  hardware.opengl = {
    enable = true;
    extraPackages = with pkgs; [
      vaapiVdpau
      libvdpau-va-gl

      rocm-opencl-icd
      rocm-opencl-runtime
    ];
  };
}

