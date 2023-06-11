{ config, services, pkgs, ... }:

{
  # Map the gitea user to postgresql's gitea-users
  services.postgresql = {
    authentication = ''
      local gitea all ident map=gitea-users
    '';
    identMap = ''
      gitea-users gitea gitea
    '';
  };

  services.gitea = {
    enable = true;
    stateDir = "/var/lib/gitea";

    database.type = "postgres";

    #domain = "code.joukamachi.net";
    #rootUrl = "https://code.joukamachi.net/";
    #httpPort = 3001;
  };
}

