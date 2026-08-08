{ lib, config, ... }: {
  programs = {
    pipewire = {
      enable = true;
      jack.enable = true;
    };
    wireplumber.enable = true;
  };
  services.rtkit.enable = true;
  services.rtkit.extraGroups = lib.optionals config.services.seatd.enable [
    config.services.seatd.group
  ];
}
