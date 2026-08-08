{
  config,
  lib,
  pkgs,
  ...
}:
let
  udevApi =
    if config.services.gardendevd.enable then
      pkgs.libudev-garden
    else if config.services.mdevd.enable || config.services.keventd.enable then
      pkgs.libudev-zero
    else
      null;

  libinput = pkgs.libinput.override (
    lib.optionalAttrs (udevApi != null) {
      udev = udevApi;
      wacomSupport = false;
    }
  );

  wlroots_0_20 = pkgs.wlroots_0_20.override {
    inherit libinput;

    # xwayland appears to cause issues - and not required in this context, so no harm in removing
    enableXWayland = false;
  };
in
{
  environment.systemPackages = with pkgs; [
    (cage.override {
      inherit wlroots_0_20;
    })
    (wrapOBS {
      plugins = with pkgs.obs-studio-plugins; [
        (distroav.override {
          ndi-6 = pkgs.ndi-6.overrideAttrs (oldAttrs: {
            src = pkgs.fetchurl {
              inherit (oldAttrs.src) url;
              hash = "sha256-8DFPJFRG3vxIi2POtGiazxqWWu79ray3BXG7IWqMwYM=";
            };
          });
        })
        obs-pipewire-audio-capture
      ];
    })
  ];

  # services.avahi = {
  #   enable = true;
  #   # TODO: Fix nssmdns.
  #   # nssmdns = true;
  #   publish = {
  #     enable = true;
  #     userServices = true;
  #   };
  # };

  # environment.etc."libinput/local-overrides.quirks".text = ''
  #   [OBS Kiosk Touchpad Override]
  #   MatchIsTouchpad=true
  #   AttrTapping=on
  # '';

  xdg.portal.portals = with pkgs; [
    xdg-desktop-portal-wlr
  ];
  xdg.portal.enable = true;

  # TODO: MOVE-ME
  finit.tasks.set-cpu-governor = {
    description = "Set CPU governor to performance";
    command = pkgs.writeShellApplication {
      name = "set-cpu-governor";
      text = ''
        for cpu in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
          echo "performance" > "$cpu" 2>/dev/null || true
        done
      '';
    };
  };
}
