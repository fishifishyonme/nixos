{ pkgs, ... }:
let
  vaapi-ov = pkgs.intel-vaapi-driver.override {
    enableHybridCodec = true;
  };
in
{
  hardware.graphics = {
    extraPackages = [
      vaapi-ov
    ]
    ++ (with pkgs; [
      intel-media-driver
      intel-compute-runtime
      intel-ocl
      mesa
    ]);
  };

  environment.variables = {
    QT_QPA_PLATFORM = "wayland";
    GDK_BACKEND = "wayland";
    ANKI_WAYLAND = "1";
    # Forces OBS/Intel to use the correct hardware acceleration backend
    LIBVA_DRIVER_NAME = "i965"; # Try "iHD" if "i965" gives encoding issues
  };
  # powerManagement.cpuFreqGovernor = "performance";
}
