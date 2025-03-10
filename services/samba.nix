{ lib, pkgs, ... }:

{
  # make shares visible in win10
  services.samba-wsdd.enable = true;
  networking.firewall.allowedTCPPorts = [ 5357 ];
  networking.firewall.allowedUDPPorts = [ 5357 ];

  services.samba = {
    enable = true;
    openFirewall = true;

    settings = {
      global = {
        "workgroup" = "POMPISH";
        "server string" = "drive";
        "netbios name" = "drive";
        "security" = "user";
        "browseable" = "yes";
        "smb encrypt" = "required";

        # only allow local network hosts
        "hosts allow" = "10.0.0. 127.0.0.1 localhost";
        "hosts deny" = "0.0.0.0/0";

        # no guests
        "guest account" = "nobody";
        "map to guest" = "bad user";
      };

      # share home dirs
      homes = {
        browseable = "no";
        "read only" = "no";
        "guest ok" = "no";
      };

      videos = {
        path = "/videos";
        browseable = "yes";
        "read only" = "no";
        "guest ok" = "no";
        "create mask" = "0644";
        "directory mask" = "0755";
        "force user" = "jellyfin";
        "force group" = "jellyfin";
      };

      appdata = {
        path = "/exports";
        browseable = "yes";
        "read only" = "no";
        "guest ok" = "no";
        "create mask" = "0644";
        "directory mask" = "0755";
      };
    };
  };

  # TODO: avahi config
}

