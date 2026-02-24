# from https://github.com/mirosval/unbound-blocklist/tree/main
{
  ...
}:

{
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;
  };

  services.snapserver = {
    enable = true;
    settings.stream = {
      codec = "flac";
      source = "pipe:///run/snapserver/pipewire?name=ttw";
    };
    openFirewall = true;
  };

  /*
    systemd.user.services.snapcast-sink = {
      wantedBy = [
        "pipewire.service"
      ];
      after = [
        "pipewire.service"
      ];
      bindsTo = [
        "pipewire.service"
      ];
      path = with pkgs; [
        gawk
        pulseaudio
      ];
      script = ''
        pactl load-module module-pipe-sink file=/run/snapserver/pipewire sink_name=Snapcast format=s16le rate=48000
      '';
    };
  */
}
