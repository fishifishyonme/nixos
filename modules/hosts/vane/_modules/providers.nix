{ config, lib, ... }: {
  providers.privileges.rules = lib.optionals config.services.seatd.enable [
    {
      command = "/run/current-system/sw/bin/poweroff";
      groups = [ config.services.seatd.group ];
      requirePassword = false;
    }
    {
      command = "/run/current-system/sw/bin/reboot";
      groups = [ config.services.seatd.group ];
      requirePassword = false;
    }
  ];
}
