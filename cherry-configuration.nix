{
  pkgs,
  ...
}:

{
  imports = [
    ./includes/rpi4.nix
    ./includes/deploy.nix
    ./includes/monitoring.nix

    # services to put here
    ./services/snapplayer.nix
  ];

  networking.hostName = "cherry";

  # Packages
  environment.systemPackages = with pkgs; [
    # customize as needed!
  ];

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "23.11";
}
