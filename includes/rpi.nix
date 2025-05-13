{ pkgs, lib, config, ... }:
# fixes for raspberry pis since they often need special handling for networking, etc
{
  services.openssh = {
    extraConfig = ''
      IPQos throughput
    '';
  };

  boot = {
    initrd.availableKernelModules = [ "xhci_pci" "usbhid" "usb_storage" ];
    loader = {
      grub.enable = false;
      generic-extlinux-compatible.enable = lib.mkDefault true;
    };
  };
  hardware.enableRedistributableFirmware = true;

  fileSystems."/" =
    { device = "/dev/mmcblk0p2";
      fsType = "ext4";
    };

  # TODO: move some of these to a general server include file
  networking.useDHCP = true;
  networking.enableIPv6 = false;

  # Packages
  environment.systemPackages = with pkgs; [
    # customize as needed!
    bash zsh vim git
    libraspberrypi
    #cifs-utils
  ];

  time.timeZone = "Europe/Vienna"; 

  # server doesn't compile on raspberry pi
  services.localtimed.enable = false;

  services.openssh.enable = true;

  # Nix
  boot.tmp.cleanOnBoot = true;

  programs.nano.enable = false;
  systemd.services.modem-manager.enable = false;

  # don't install man pages to save space
  documentation.man.enable = false;
  documentation.nixos.enable = false;


}
