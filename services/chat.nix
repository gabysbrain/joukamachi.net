{
  config,
  ...
}:

{
  age.secrets.matrix-sso-secret.file = ../secrets/matrix-sso-secret.age;
  services.matrix-tuwunel = {
    enable = true;
    settings = {
      allow_federation = false;
      global.server_name = "joukamachi.net";
      global.identity_provider = {
        brand = "Authelia";
        client_id = "matrix";
        client_secret_file = config.age.secrets.matrix-sso-secret.path;
        issuer_url = "https://auth.joukamachi.net";
        callback_url = "https://my.tld.it/_matrix/client/unstable/login/sso/callback/matrix";
        name = "Authelia";
      };
    };
  };
}
