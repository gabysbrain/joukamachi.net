{
  # user to log in for remote deployment
  users.extraUsers.deploy = {
    uid = 2000; # keep is out of range of login users
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    homeMode = "500";
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBtxo+1CFuJFBHErjV1tKala+2i7N7PDfBvX2Oa+nYGd tom@philadelphia"
    ];
  };

  nix.settings.trusted-users = [ "deploy" ];

  security.sudo = {
    enable = true;
    extraRules = [
      {
        users = [ "deploy" ];
        commands = [
          {
            command = "ALL";
            options = [ "NOPASSWD" ];
          }
        ];
      }
    ];
  };

  # user for application filesharing
  users.extraUsers.appshare = {
    uid = 2001;
    isSystemUser = true;
    group = "appshare";
  };
  users.groups.appshare = { };

  # needed for nix flake support
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
}
