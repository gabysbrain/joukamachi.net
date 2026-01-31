{
  config,
  services,
  pkgs,
  ...
}:

{
  services.jellyfin.enable = true;

  # hardware transcoding
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      libva-vdpau-driver
      libvdpau-va-gl

      rocmPackages.clr
    ];
  };
}
