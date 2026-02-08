{
  ...
}:

{
  services.matrix-tuwunel = {
    enable = true;
    settings = {
      allow_federation = false;
      global.server_name = "joukamachi.net";
    };
  };
}
