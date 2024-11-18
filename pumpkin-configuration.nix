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

  networking.hostName = "pumpkin";

  # Packages
  environment.systemPackages = with pkgs; [
    # customize as needed!
  ];

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "23.11";
}
