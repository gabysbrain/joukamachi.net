{
  pkgs,
  ...
}:

{
  imports = [
    ./includes/rpi3.nix
    ./includes/deploy.nix
    ./includes/monitoring.nix

    # services to put here
    ./services/zigbee.nix
  ];

  networking.hostName = "bananacreme";

  # Packages
  environment.systemPackages = with pkgs; [
    # customize as needed!
    #podman
  ];

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "24.05";
}
