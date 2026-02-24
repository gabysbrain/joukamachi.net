{
  config,
  pkgs,
  services,
  ...
}:

{
  services.grocy = {
    enable = true;
    hostName = "grocy.joukamachi.net";
    #nginx.enableSSL = false;
    nginx.enableSSL = true;
    dataDir = "/var/lib/grocy";
    settings.currency = "EUR";
  };

  services.nginx = {
    # the grocy service has its own virtualhost spec
    # but need to set this up for dns-based ACME
    virtualHosts."grocy.joukamachi.net" = {
      acmeRoot = null;
    };
  };
}
