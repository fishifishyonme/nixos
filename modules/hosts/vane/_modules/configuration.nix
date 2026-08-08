{
  config,
  self,
  pkgs,
  ...
}:
{
  finit.runlevel = 3;
  boot.kernelPackages = pkgs.linuxPackages_zen;

  networking.hostName = "vane";
  time.timeZone = "Asia/Manila";
}
