let
  # NOTE: secrets need to be assigned to both users (for agenix command) and systems (for agenix serivce)
  tom = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGJQREmqaoPzlEQZfnOVZqH7rWkYaUuWmoQ2T5daJ/uU";
  me = [ tom ];

  kura = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIYir4CQI59VWm2Jxbk2FiIkwIPDhMq6zG0Z6XDLBjqx";
  apple = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBRmE1oaXmEd/7j0MqUOTnzZCOF+iCcwqnWTP0nkwY2a";
  servers = [ kura apple ];

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
  "mopidy-jellyfin-conf.age".publicKeys = me ++ servers;
}
