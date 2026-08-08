{ ... }: {
  # allin fallback since i got lazy
  services = {
    sysklogd.enable = true;
    dbus.enable = true;
    mdevd = {
      enable = true;
      nlgroups = 4;
    };
    dhcpcd.enable = true;
    seatd.enable = true;
  };
}
