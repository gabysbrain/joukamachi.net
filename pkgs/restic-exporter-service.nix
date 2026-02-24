{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.services.restic-exporter;
  restic-exporter-pkg = pkgs.callPackage ./restic-exporter.nix { };
in

with lib;

{
  options = {
    services.restic-exporter = {
      enable = mkOption {
        default = false;
        type = with types; bool;
        description = ''
          Start restic-exporter
        '';
      };

      repoUrl = mkOption {
        type = types.str;
        description = ''
          Restic repository URL
        '';
      };

      repoPasswordFile = mkOption {
        type = types.path;
        description = ''
          Restic repository password file
        '';
      };

      refreshInterval = mkOption {
        # FIXME: positive interger!
        type = types.int;
        default = 60;
        example = 10;
        description = ''
          How often to recompute metrics (in seconds)
        '';
      };

      noCheck = mkOption {
        type = types.bool;
        default = false;
        example = true;
        description = ''
          Whether or not to run restic check
        '';
      };

      user = mkOption {
        default = "restic"; # FIXME: grab name from restic server config
        type = types.str;
        description = ''
          Username that runs the service
        '';
      };

      address = mkOption {
        type = types.str;
        default = "127.0.0.1";
        description = ''
          Address the listener should listen on
        '';
      };

      port = mkOption {
        type = types.port;
        default = 8001;
        description = ''
          Port the listener should listen on
        '';
      };
    };
  };

  config = mkIf cfg.enable {
    systemd.services.restic-exporter = {
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];
      description = "Monitor restic metrics";
      serviceConfig = {
        Type = "simple";
        User = "${cfg.user}";
        ExecStart = "${restic-exporter-pkg}/bin/restic-exporter";

        # Security hardening
        PrivateTmp = true;
        ProtectSystem = "strict";
        ProtectKernelTunables = true;
        ProtectKernelModules = true;
        ProtectControlGroups = true;
        PrivateDevices = true;
      };
      environment = {
        RESTIC_REPO_URL = cfg.repoUrl;
        RESTIC_REPO_PASSWORD_FILE = cfg.repoPasswordFile;
        REFRESH_INTERVAL = toString cfg.refreshInterval;

        LISTEN_ADDRESS = cfg.address;
        LISTEN_PORT = toString cfg.port;

        NO_CHECK = toString cfg.noCheck;
      };
    };
  };
}
