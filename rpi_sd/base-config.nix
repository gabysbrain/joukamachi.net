{ pkgs, lib, config, ... }:

{
  hardware.enableRedistributableFirmware = true;

  #networking.hostName = "nixpi"; # unleash your creativity!
  networking.hostName = "newrpi";

  # auto login as root
  services.openssh = {
    enable = true;
    settings.PermitRootLogin = "yes";
  };
  
  users.users.nixos = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "video" ];
    initialPassword = "nixos";
  };
  services.getty.autologinUser = "nixos";

  users.users.root.initialPassword = "nixos"; # Log in without a password

  networking.useDHCP = true;
  networking.enableIPv6 = false;

  # Packages
  environment.systemPackages = with pkgs; [
    # customize as needed!
    bash zsh vim git
    libraspberrypi
  ];

  time.timeZone = "Europe/Vienna"; 

  # server doesn't compile on raspberry pi
  services.localtimed.enable = false;

  # WARNING: if you remove this, then you need to assign a password to your user, otherwise
  # `sudo` won't work. You can do that either by using `passwd` after the first rebuild or
  # by setting an hashed password in the `users.users.yourName` block as `initialHashedPassword`.
  security.sudo.wheelNeedsPassword = false;
  users.users.root = {
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGJQREmqaoPzlEQZfnOVZqH7rWkYaUuWmoQ2T5daJ/uU tom@tomtorsneyweir.com"
    ];
  };
  
  # Nix
  boot.tmp.cleanOnBoot = true;

  # don't install man pages to save space
  documentation.man.enable = false;
  documentation.nixos.enable = false;

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "23.05";
}
