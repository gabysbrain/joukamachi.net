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
      endpointAuthMethod ? "client_secret_basic",
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
      token_endpoint_auth_method = endpointAuthMethod;
    };
  oidcConfigs = [
    {
      clientId = "immich";
      clientSecret = "$pbkdf2-sha512$310000$dHP.P8zy0RLgLsPrORGjkg$s2N/VTVR43gXyStqezY5iRnBw8myVv5y/Wo4ENmPJC9qXYOcfL06KUFIB55Gx1RbaRsvgEjZqYOO3yZNdJrMFQ";
      #pkceChallengeMethod = "";
      redirectUris = [
        "https://photos.joukamachi.net/auth/login"
        "https://photos.joukamachi.net/user-settings"
        "app.immich:///oauth-callback"
      ];
      scopes = [
        "openid"
        "profile"
        "email"
      ];
      endpointAuthMethod = "client_secret_post";
    }
    {
      clientId = "jellyfin";
      clientSecret = "$pbkdf2-sha512$310000$BBF0LTqigHKVEwEZZ22jTg$IgoG0Pfc5ke9wECu4f0Mz9HvwmsqG3GnEjPI5Ej78u42LyFFPcx.gShnG7.ozBMh6r5j4lenayrlZts0g6GRow";
      pkceChallengeMethod = "S256";
      redirectUris = [
        "https://media.joukamachi.net/sso/OID/redirect/authelia"
      ];
      scopes = [
        "openid"
        "profile"
        "groups"
      ];
      endpointAuthMethod = "client_secret_post";
    }
    {
      clientId = "forgejo";
      clientSecret = "$pbkdf2-sha512$310000$s6iR8ig28g5ZQrVEaTbKaw$GFDq7LTia45vsKILS4ueDc0RZbY0WHIfKTGJwxdKPkOWzyLEHnqToN1QCSsVKBeIIvg5zi435/6kbT/uc5qpwA";
      pkceChallengeMethod = "S256";
      redirectUris = [
        "https://code.joukamachi.net/user/oauth2/authelia/callback"
      ];
      scopes = [
        "openid"
        "email"
        "profile"
        "groups"
      ];
    }
    {
      clientId = "grafana";
      clientSecret = "$pbkdf2-sha512$310000$22mNXKlTScPtJ8e9tYGH3Q$bd2E.ne2GkQf/RgPoPp1tBwHydaTKcCdg6t62/KwIK7B07R5nKkOyi1bgekPyUKDNtMTwDSgel3UBUW4C5rmDg";
      #pkceChallengeMethod = "S256";
      redirectUris = [
        "https://monitor.joukamachi.net/login/generic_oauth"
      ];
      scopes = [
        "openid"
        "email"
        "profile"
        "groups"
      ];
    }
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
  age.secrets.authelia-oidc-issuer = {
    file = ../secrets/authelia-oidc-issuer.age;
    owner = config.services.authelia.instances.main.user;
  };
  age.secrets.authelia-pg-pw = {
    file = ../secrets/authelia-pg-pw.age;
    owner = config.services.authelia.instances.main.user;
  };
  age.secrets.gmail-pw = {
    file = ../secrets/gmail-pw.age;
    owner = config.services.authelia.instances.main.user;
  };
  services.authelia.instances.main = {
    enable = true;
    secrets = {
      storageEncryptionKeyFile = config.age.secrets.authelia-storage-key.path;
      jwtSecretFile = config.age.secrets.authelia-jwt-secret.path;
      sessionSecretFile = config.age.secrets.authelia-session-secret.path;
      oidcIssuerPrivateKeyFile = config.age.secrets.authelia-oidc-issuer.path;
    };
    environmentVariables = {
      # these aren't in secrets
      "AUTHELIA_AUTHENTICATION_BACKEND_LDAP_PASSWORD_FILE" = config.age.secrets.authelia-ldap-pw.path;
      "AUTHELIA_STORAGE_POSTGRES_PASSWORD_FILE" = config.age.secrets.authelia-pg-pw.path;
      "AUTHELIA_NOTIFIER_SMTP_PASSWORD_FILE" = config.age.secrets.gmail-pw.path;
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
        smtp = {
          address = "submission://smtp.gmail.com:587";
          username = "torsneyt@gmail.com";
          sender = "auth@joukamachi.net";
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
