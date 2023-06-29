{ pkgs, lib, config, ... }:

{
  imports =
    [ 
      ./includes/common.nix

      # services to put here
    ];

  hardware.enableRedistributableFirmware = true;

  networking.hostName = "apple";

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

  # filesystems for protoprism
  fileSystems."/var/lib/private/photoprism" = {
    device = "//drive.joukamachi.net/exports/photoprism-cagla";
    fsType = "cifs";
    #options = let
        ## this line prevents hanging on network split
        #automount_opts = "x-systemd.automount,noauto,x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s";

      #in ["${automount_opts},credentials=/etc/nixos/smb-secrets"];
  };

  # Nix
  boot.tmp.cleanOnBoot = true;

  # don't install man pages to save space
  documentation.man.enable = false;
  documentation.nixos.enable = false;

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "23.05";
}
