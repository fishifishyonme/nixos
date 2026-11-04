{
  self,
  pkgs,
  config,
  lib,
  ...
}:
{
  specialisation = {
    vane = {
      toplevel =
        self.legacyPackages."${pkgs.stdenv.hostPlatform.system
        }".nixosConfigurations.vane.config.system.build.toplevel;
    };
  };
}
