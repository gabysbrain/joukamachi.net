{ pkgs, config, ... }:
{
  # cross-compile arch64
  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  age.secrets.forgejo-runner-token.file = ../secrets/forgejo-runner-token.age;

  # podman or docker needed for vistualized runner hosts
  virtualisation = {
    containers.enable = true;
    podman = {
      enable = true;
      dockerCompat = true;
      defaultNetwork.settings.dns_enabled = true;
    };
  };

  services.gitea-actions-runner = {
    package = pkgs.forgejo-runner;
    instances.default = {
      enable = true;
      name = "kura";
      url = "https://code.joukamachi.net";
      # Obtaining the path to the runner token file may differ
      # tokenFile should be in format TOKEN=<secret>, since it's EnvironmentFile for systemd
      tokenFile = config.age.secrets.forgejo-runner-token.path;
      labels = [
        "ubuntu-latest:docker://node:16-bullseye"
        "ubuntu-22.04:docker://node:16-bullseye"
        "ubuntu-20.04:docker://node:16-bullseye"
        "ubuntu-18.04:docker://node:16-buster"
        ## optionally provide native execution on the host:
        "native:host"
      ];
      hostPackages = with pkgs; [
        bash
        coreutils
        curl
        gawk
        gitMinimal
        gnused
        gnumake
        nix
        nodejs
        wget
      ];
    };
  };
}
