{
  ...
}:

{
  services.matrix-tuwunel = {
    enable = true;
    settings = {
      global.allow_federation = false;
      global.server_name = "joukamachi.net";
    };
  };
}
