{
  config,
  pkgs,
  services,
  ...
}:

{
  age.secrets.authentik-env.file = ../secrets/authentik-env.age;
  services.authentik = {
    enable = true;
    environmentFile = "${config.age.secrets.authentik-env.path}";
    createDatabase = false; # mistakenly starts a db on the same host as authentik
    nginx.enable = false; # mistakenly starts nginx on the same host
    settings = {
      postgresql = {
        host = "db.joukamachi.net";
      };
    };
    diable_startup_analytics = true;
    avatars = "initials";
  };
}
