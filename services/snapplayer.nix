# from https://github.com/mirosval/unbound-blocklist/tree/main
{
  config,
  lib,
  pkgs,
  ...
}:

{
  #security.rtkit.enable = true;
  #services.pipewire = {
  #enable = true;
  #alsa.enable = true;
  #alsa.support32Bit = true;
  #pulse.enable = true;
  ## If you want to use JACK applications, uncomment this
  ##jack.enable = true;
  #};
  hardware.pulseaudio.enable = true;

  systemd.services.snapplayer = {
    wantedBy = [ "multi-user.target" ];
    after = [ "sound.target" ];
    #wantedBy = [
    #"pipewire.service"
    #];
    #after = [
    #"pipewire.service"
    #];
    serviceConfig = {
      ExecStart = "${pkgs.snapcast}/bin/snapclient -s 1 -h snapserver.joukamachi.net --hostID office";
    };
  };

  environment.systemPackages = with pkgs; [
    snapcast
  ];
}
