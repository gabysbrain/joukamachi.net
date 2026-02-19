{
  config,
  pkgs,
  services,
  ...
}:

let
  defaultConfig =
    {
      clientId,
      clientSecret,
      pkceChallengeMethod ? "",
      redirectUris,
      scopes,
    }:
    {
      client_id = clientId;
      client_name = clientId;
      client_secret = clientSecret;
      public = false;
      authorization_policy = "two_factor";
      require_pkce = pkceChallengeMethod != "";
      pkce_challenge_method = pkceChallengeMethod;
      redirect_uris = redirectUris;
      scopes = scopes;
      response_types = [ "code" ];
      grant_types = [ "authorization_code" ];
      access_token_signed_response_alg = "none";
      userinfo_signed_response_alg = "none";
      token_endpoint_auth_method = "client_secret_basic";
    };
  oidcConfigs = [
  ];
in
{
  age.secrets.portunus-seedfile = {
    file = ../secrets/portunus-seedfile.age;
    owner = config.services.portunus.user;
  };
  services.portunus = {
    enable = true;
    domain = "sso.joukamachi.net";
    port = 17170;
    ldap = {
      suffix = "dc=joukamachi,dc=net";
    };
    seedPath = config.age.secrets.portunus-seedfile.path;
  };
  systemd.services.portunus.environment.PORTUNUS_SERVER_HTTP_LISTEN =
    pkgs.lib.mkForce "[::]:${toString config.services.portunus.port}";

  age.secrets.authelia-jwt-secret = {
    file = ../secrets/authelia-jwt-secret.age;
    owner = config.services.authelia.instances.main.user;
  };
  age.secrets.authelia-storage-key = {
    file = ../secrets/authelia-storage-key.age;
    owner = config.services.authelia.instances.main.user;
  };
  age.secrets.authelia-session-secret = {
    file = ../secrets/authelia-session-secret.age;
    owner = config.services.authelia.instances.main.user;
  };
  age.secrets.authelia-ldap-pw = {
    file = ../secrets/authelia-ldap-pw.age;
    owner = config.services.authelia.instances.main.user;
  };
  age.secrets.authelia-pg-pw = {
    file = ../secrets/authelia-pg-pw.age;
    owner = config.services.authelia.instances.main.user;
  };
  services.authelia.instances.main = {
    enable = true;
    secrets = {
      storageEncryptionKeyFile = config.age.secrets.authelia-storage-key.path;
      jwtSecretFile = config.age.secrets.authelia-jwt-secret.path;
      sessionSecretFile = config.age.secrets.authelia-session-secret.path;
    };
    environmentVariables = {
      # these aren't in secrets
      "AUTHELIA_AUTHENTICATION_BACKEND_LDAP_PASSWORD_FILE" = config.age.secrets.authelia-ldap-pw.path;
      "AUTHELIA_STORAGE_POSTGRES_PASSWORD_FILE" = config.age.secrets.authelia-pg-pw.path;
    };
    settings = {
      theme = "auto";
      default_2fa_method = "totp";
      log.level = "debug";
      server.disable_healthcheck = true;
      server.address = "tcp://0.0.0.0:9091/";

      identity_providers.oidc.clients = map defaultConfig oidcConfigs;
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
          users_filter = "(&(objectclass=person)(|({username_attribute}={input})({mail_attribute}={input})))";
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

  networking.firewall.allowedTCPPorts = [
    config.services.portunus.port
    9091
  ];
}
