let
  # NOTE: secrets need to be assigned to both users (for agenix command) and systems (for agenix serivce)
  tom = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGJQREmqaoPzlEQZfnOVZqH7rWkYaUuWmoQ2T5daJ/uU";
  me = [ tom ];

  kura = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIYir4CQI59VWm2Jxbk2FiIkwIPDhMq6zG0Z6XDLBjqx";
  apple = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBRmE1oaXmEd/7j0MqUOTnzZCOF+iCcwqnWTP0nkwY2a";
  servers = [
    kura
    apple
  ];

  #backup = [ philadelphia katana util ];

in
{
  "restic.age".publicKeys = me ++ servers;
  "rclone-backblaze.age".publicKeys = me ++ servers;
  "digitalocean.age".publicKeys = me ++ servers;
  "restic-exporter-env.age".publicKeys = me ++ servers;
  "appshare-smb.age".publicKeys = me ++ servers;
  "immichdb-pw.age".publicKeys = me ++ [ kura ];
  "immich-secrets.age".publicKeys = me ++ [ kura ];
  "gmail-pw.age".publicKeys = me ++ [ apple ];
  "mopidy-jellyfin-conf.age".publicKeys = me ++ servers;
  "portunus-seedfile.age".publicKeys = me ++ [ apple ];
  "atticd-env.age".publicKeys = me ++ servers;
  "forgejo-runner-token.age".publicKeys = me ++ servers;
  "authelia-jwt-secret.age".publicKeys = me ++ [ apple ];
  "authelia-ldap-pw.age".publicKeys = me ++ [ apple ];
  "authelia-oidc-issuer.age".publicKeys = me ++ [ apple ];
  "authelia-pg-pw.age".publicKeys = me ++ [ apple ];
  "authelia-storage-key.age".publicKeys = me ++ [ apple ];
  "authelia-session-secret.age".publicKeys = me ++ [ apple ];
}
