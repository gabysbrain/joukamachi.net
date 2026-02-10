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

  services.authelia.instances.main = {
    enable = true;
    secrets = {
      storageEncryptionKeyFile = config.age.secrets.authelia-storage-key.path;
      jwtSecretFile = config.age.secrets.authelia-jwt-secret.path;
      sessionSecretFile = config.age.secrets.authelia-session-secret.path;
    };
    settings = {
      theme = "auto";
      default_2fa_method = "totp";
      log.level = "debug";
      server.disable_healthcheck = true;
      server.address = "tcp://0.0.0.0:9091/";

      access_control = {
        default_policy = "deny";
        rules = [
          {
            domain = [ "auth.joukamachi.net" ];
            policy = "bypass";
          }
          {
            domain = [ "*.joukamachi.net" ];
            policy = "one_factor";
          }
        ];
      };

      session = {
        name = "authelia_session";
        expiration = "12h";
        inactivity = "45m";
        remember_me = "1M";
        cookies = [
          {
            domain = "joukamachi.net";
            authelia_url = "https://auth.joukamachi.net";
            name = "authelia_session";
          }
        ];
      };

      notifier = {
        disable_startup_check = false;
        filesystem = {
          filename = "/var/lib/authelia-main/notification.txt";
        };
      };

      authentication_backend = {
        ldap = {
          # FIXME: ldap is mapped to kura for revproxy reasons :/
          address = "ldap://apple.joukamachi.net";
          user = "uid=admin,ou=users,dc=joukamachi,dc=net"; # FIXME: there must be a better choice
          base_dn = "dc=joukamachi,dc=net";
          users_filter = "(&(objectclass=person)({username_attribute}={input}))";
          additional_groups_dn = "ou=groups";
          groups_filter = "(&(objectclass=person)(isMemberOf=cn={dn},ou=groups,dc=joukamachi,dc=net))";
          group_search_mode = "filter";
          permit_referrals = false;
          permit_unauthenticated_bind = false;
          permit_feature_detection_failure = false;
        };
      };

      storage = {
        postgres = {
          address = "tcp://db.joukamachi.net:5432";
          database = "authelia";
          username = "authelia";
        };
      };
    };
  };
}
