let
  # NOTE: secrets need to be assigned to both users (for agenix command) and systems (for agenix serivce)
  tom = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGJQREmqaoPzlEQZfnOVZqH7rWkYaUuWmoQ2T5daJ/uU";
  me = [ tom ];

  kura = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIYir4CQI59VWm2Jxbk2FiIkwIPDhMq6zG0Z6XDLBjqx";
  apple = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIP1TJx/wzaItVetBp4HM7hB9DRGSLuk+rJMKHQZafCtq";
  servers = [ kura apple ];

  #backup = [ philadelphia katana util ];

in
{
  "wasabi.age".publicKeys = me ++ servers;
  "restic.age".publicKeys = me ++ servers;
  "rclone-wasabi.age".publicKeys = me ++ servers;
  "digitalocean.age".publicKeys = me ++ servers;
  "restic-exporter-env.age".publicKeys = me ++ servers;
  "appshare-smb.age".publicKeys = me ++ servers;
}
