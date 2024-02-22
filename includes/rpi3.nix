{ pkgs, lib, config, ... }:
# fixes for raspberry pis since they often need special handling for networking, etc
{
  imports = [ ./rpi.nix ];

  boot = {
    kernelPackages = pkgs.linuxKernel.packages.linux_rpi4;
    initrd.availableKernelModules = [ "xhci_pci" "usbhid" "usb_storage" ];
    loader = {
      grub.enable = false;
      generic-extlinux-compatible.enable = true;
    };
  };

  services.openssh = {
    extraConfig = ''
      IPQos 0x00
    '';
  };
}
