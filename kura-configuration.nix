# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running `nixos-help`).

{ config, lib, pkgs, modulesPath, ... }:

{
  imports =
    [ 
      (modulesPath + "/installer/scan/not-detected.nix")
      ./includes/common.nix

      # services to put here
      # TODO: put these in the flake file to get an overview of what services are running where 
      ./services/restic-server.nix
      ./services/jellyfin.nix
      ./services/postgres.nix
      ./services/mysql.nix
      ./services/gitea.nix
      ./services/monitoring.nix
      ./services/loki.nix
      ./services/revproxy.nix
      ./services/samba.nix
      ./services/photos.nix
    ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "nvme" "usb_storage" "usbhid" "sd_mod" ];
  boot.initrd.kernelModules = [ "dm-snapshot" ];
  boot.kernelModules = [ "kvm-amd" "amdgpu" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    { device = "/dev/disk/by-label/root";
      fsType = "ext4";
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-label/BOOT";
      fsType = "vfat";
    };

  swapDevices =
    [ { device = "/dev/disk/by-label/swap"; }
    ];

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.enp42s0.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # zfs config
  boot.supportedFilesystems = [ "zfs" ];
  boot.zfs.forceImportRoot = false;
  boot.zfs.devNodes = "/dev/disk/by-id";
  boot.zfs.extraPools = [ "backup" "store" ];
  networking.hostId = "b17f36e0"; # for zfs

  fileSystems."/home" = {
    device = "store/homes";
    fsType = "zfs";
  };

  # TODO: make this a loop
  fileSystems."/home/tom/music" = {
    device = "/music/tom";
    options = [ "bind" ];
  };
  fileSystems."/home/tom/home-movies" = {
    device = "/home-movies/library/tom";
    options = [ "bind" ];
  };
  fileSystems."/home/cagla/music" = {
    device = "/music/cagla";
    options = [ "bind" ];
  };
  fileSystems."/home/cagla/home-movies" = {
    device = "/home-movies/library/cagla";
    options = [ "bind" ];
  };


  # influxdb2 desperately wants to run out of /var/lib/influxdb2
  fileSystems."/var/lib/influxdb2" = {
    device = "/db/influxdb";
    options = [ "bind" ];
  };

  networking.hostName = "kura"; # Define your hostname.
  # Pick only one of the below networking options.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  # networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.

  # Set your time zone.
  time.timeZone = "Europe/Vienna";

  # FIXME: remove copy/paste
  # backup restic data stores
  age.secrets.restic.file = ./secrets/restic.age;
  services.restic.backups = {
    local = {
      paths = [ "/home-movies" "/music" "/home" "/videos" "/var/lib/gitea" ];
      repository = "rest:https://backup.joukamachi.net";
      passwordFile = config.age.secrets.restic.path;
      exclude = [
        "videos/**/replaceable"
        "videos/**/drm"
      ];
      pruneOpts = [
        "--keep-within-daily 7d"
        "--keep-within-weekly 2m"
        "--keep-within-monthly 2y"
        "--keep-within-yearly 20y"
        "--keep-last 2"
        "--compression max"
      ];
      timerConfig = {
        OnCalendar = "00:20";
        RandomizedDelaySec = "2h";
        Persistent = true;
      };
    };
  };

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.tom = {
    isNormalUser = true;
    extraGroups = [ "wheel" "jellyfin" "docker" ]; # Enable ‘sudo’ for the user.
  };

  users.users.cagla = {
    isNormalUser = true;
    extraGroups = [ "wheel" "jellyfin" ]; # Enable ‘sudo’ for the user.
  };


  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    git
    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
  #   wget
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # export node status to prometheus
  services.prometheus.enable = true;
  services.prometheus = {
    exporters = {
      node = {
        enable = true;
        enabledCollectors = [ "systemd" ];
        port = 9002;
      };
    };
  };
  
  # auto gc
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?

}

