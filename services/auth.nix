{
  config,
  pkgs,
  services,
  ...
}:

{
  services.portunus = {
    enable = true;
    domain = "sso.joukamachi.net";
    port = 17170;
    ldap = {
      suffix = "dc=joukamachi,dc=net";
    };
  };
}
