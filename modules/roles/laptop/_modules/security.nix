{ self, ... }:
{
  security.rtkit.enable = true;
  security.protectKernelImage = true;

  security.polkit.enable = true;
  security.sudo.enable = false;
  security.doas.enable = true;
  security.doas.extraRules = [
    {
      users = [ "fish" ];
      # Optional, retains environment variables while running commands
      # e.g. retains your NIX_PATH when applying your config
      keepEnv = true;
      persist = true; # Optional, don't ask for the password for some time, after a successfully authentication
    }
  ];

  # FIXME: Probably better to move this onto programs/niri?
  services.gnome.gnome-keyring.enable = true; # secret service
}
