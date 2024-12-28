{ pkgs, lib, config, ... }:
# fixes for raspberry pis since they often need special handling for networking, etc
{
  services.openssh = {
    extraConfig = ''
      IPQos throughput
    '';
  };

  boot.loader.generic-extlinux-compatible.enable = lib.mkDefault true;
  #boot.loader.raspberryPi.firmwareConfig = ''
    #dtparam=audio=on
  #'';

  # TODO: move some of these to a general server include file
  networking.useDHCP = true;
  networking.enableIPv6 = false;

  # Packages
  environment.systemPackages = with pkgs; [
    # customize as needed!
    bash zsh vim git
    libraspberrypi
    cifs-utils
  ];

  time.timeZone = "Europe/Vienna"; 

  # server doesn't compile on raspberry pi
  services.localtimed.enable = false;

  services.openssh.enable = true;

  # Nix
  boot.tmp.cleanOnBoot = true;

  # don't install man pages to save space
  documentation.man.enable = false;
  documentation.nixos.enable = false;


}
