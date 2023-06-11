{ config, services, pkgs, ... }:

#let
  #rclone-filters = ''
    #- .cache
  #'';
#in
{
  services.restic.server = {
    enable = true;
    dataDir = "/backup";
    listenAddress = "127.0.0.1:8000";

    # FIXME: maybe we want auth?
    extraFlags = [
      "--no-auth"
    ];

    prometheus = true;
  };

  # push to s3
  # HACK: get these out of /etc/ and just the store
  #environment.etc."rclone-offsite/filters.conf" = {
    #user = "restic";
    #group = "restic";
    #text = rclone-filters;
  #};
  # rclone bisync needs an md5 hash of the filters
  #environment.etc."rclone-offsite/filters.conf.md5" = {
    #user = "restic";
    #group = "restic";
    #text = (builtins.hashString "md5" rclone-filters);
  #};
  age.secrets.rclone-config = {
    owner = "restic";
    group = "restic";
    file = ../secrets/rclone-wasabi.age;
  };
  systemd.services.restic-offsite = {
    serviceConfig = {
      Type = "oneshot";
      User = "restic";
      Group = "restic";
      # TODO: use bisync one day
      ExecStart = ''
        ${pkgs.rclone}/bin/rclone \
          -v --stats-log-level NOTICE \
          --config ${config.age.secrets.rclone-config.path} \
          sync /backup wasabi:gabysbrain-restic
      '';
    };
  };
  systemd.timers.restic-offsite = {
    wantedBy = [ "timers.target" ];
    partOf = [ "restic-offsite.service" ];
    timerConfig = {
      OnCalendar = "4:05:00";
      Unit = "restic-offsite.service";
    };
  };
}

