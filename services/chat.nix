{
  config,
  ...
}:

{
  age.secrets.tuwunel-reg-token = {
    file = ../secrets/tuwunel-reg-token.age;
    owner = config.services.matrix-tuwunel.user;
  };
  services.matrix-tuwunel = {
    enable = true;
    settings = {
      global.allow_federation = false;
      global.allow_registration = true;
      global.registration_token_file = config.age.secrets.tuwunel-reg-token.path;
      global.server_name = "joukamachi.net";
    };
  };
}
