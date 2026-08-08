{
  self,
  inputs,
  ...
}:
{
  # workaround
  perSystem = { pkgs, system, ... }: {
    legacyPackages.nixosConfigurations.vane = inputs.finix.lib.finixSystem {
      inherit (pkgs) lib;
      modules =
        with inputs.finix.nixosModules;
        [
          nix-daemon
          sudo
          getty
          bash
          sysklogd
          dhcpcd
          limine
          nftables
          polkit
          pipewire
          rtkit
          wireplumber
          #setup.
          {
            nixpkgs.pkgs = inputs.nixpkgs.lib.mkDefault (
              import inputs.nixpkgs {
                inherit pkgs system;
                config.allowUnfree = true;
              }
            );
          }

          (inputs.import-tree ./_modules)
        ]
        ++ (with inputs.finix-modules.nixosModules; [
          preservation
        ]);
      specialArgs = {
        inherit self;
        modulesPath = toString inputs.nixpkgs + "/nixos/modules";
      };
    };
  };
}
