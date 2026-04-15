{
  config,
  ...
}:

{
  age.secrets.syncthing-gui-pw.file = ../secrets/syncthing-gui-pw.age;
  services.syncthing = {
    enable = true;
    openDefaultPorts = true;

    settings.gui = {
      user = "tom";
    };
    guiPasswordFile = config.age.secrets.syncthing-gui-pw.path;
  };
}
