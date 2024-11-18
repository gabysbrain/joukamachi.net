{ pkgs, lib, config, ... }:
# fixes for raspberry pis since they often need special handling for networking, etc
{
  imports = [ ./rpi.nix ];

  boot = {
    initrd.availableKernelModules = [ "xhci_pci" "usbhid" "usb_storage" ];
    loader = {
      grub.enable = false;
      generic-extlinux-compatible.enable = true;
    };
  };
  hardware.enableRedistributableFirmware = true;

  fileSystems."/" =
    { device = "/dev/mmcblk0p2";
      fsType = "ext4";
    };


}
