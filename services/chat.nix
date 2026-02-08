{
  config,
  pkgs,
  services,
  ...
}:

{
  services.matrix-synapse = {
    enable = true;
    settings = {
      public_baseurl = "chat.joukamachi.net";
      server_name = "joukamachi.net";
      listeners = [
        {
          port = 8008;
          bind_addresses = [ "::1" ];
          type = "http";
          tls = false;
          x_forwarded = true;
          resources = [
            {
              names = [
                "client"
                "federation"
              ];
              compress = true;
            }
          ];
        }
      ];
    };
  };
}
