{
  ...
}:

{
  # Map the gitea user to postgresql's gitea-users
  #services.postgresql = {
  #authentication = ''
  #local gitea all ident map=gitea-users
  #'';
  #identMap = ''
  #gitea-users gitea gitea
  #'';
  #};

  services.forgejo = {
    enable = true;
    stateDir = "/var/lib/forgejo";

    database.type = "postgres";

    settings.server = {
      PROTOCOL = "http";
      HTTP_PORT = 3001;
      ROOT_URL = "https://code.joukamachi.net/";
      DOMAIN = "code.joukamachi.net";
    };
  };
}
