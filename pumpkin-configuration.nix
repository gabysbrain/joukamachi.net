{ pkgs, lib, config, ... }:

{
  imports =
    [ 
      ./includes/rpi3.nix
      ./includes/deploy.nix
      ./includes/monitoring.nix

      # services to put here
      ./services/dns.nix
      ./services/redis.nix
    ];

  hardware.enableRedistributableFirmware = true;

  networking.hostName = "pumpkin";

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

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "23.11";
}
