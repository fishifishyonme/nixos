{
  self,
  ...
}:
{
  flake.nixosConfigurations.siesta = self.inputs.nixpkgs.lib.nixosSystem {
    specialArgs = {
      inherit self;
    };
    modules = [
      (self.inputs.import-tree ./_modules)
      self.users.fish
      self.nixosModules.laptop
      self.inputs.rehomify.nixosModules.rehomify
      {
        # Host specific declarations

        # TODO: Remove once nixos reaches NixOS 27.05
        nixpkgs.config = {
          problems.handlers = {
            "gtk+".broken = "warn"; # or "ignore"
          };
        };

        # TODO: Move this in the impermanence module.
        powerManagement.cpuFreqGovernor = "performance";
        rehomify.enable = true;
        security.sudo.extraConfig = "Defaults lecture=never";
        services.journald.storage = "persistent";
        users.mutableUsers = false;
        networking.hostName = "siesta";
        time.timeZone = "Asia/Manila";
        i18n.defaultLocale = "en_US.UTF-8";
        system.stateVersion = "26.05";
        nix.nixPath = [ "nixpkgs=${self.inputs.nixpkgs}" ];
      }
    ];
  };
}
