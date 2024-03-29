{ pkgs, lib, config, ... }:
# fixes for raspberry pis since they often need special handling for networking, etc
{
  services.openssh = {
    extraConfig = ''
      IPQos 0x00
    '';
  };

  boot.loader.raspberryPi.firmwareConfig = ''
    dtparam=audio=on
  '';
}
