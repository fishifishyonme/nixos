{
  inputs,
  self,
  withSystem,
  ...
}:
{
  perSystem =
    { system, lib, ... }:
    let
      # 1. Fetch and patch the raw nixpkgs codebase tree dynamically for this system
      patchedNixpkgsSrc = (import inputs.nixpkgs { inherit system; }).applyPatches {
        name = "nixpkgs-patched-specialisation-toplevel";
        src = inputs.nixpkgs;
        patches = [
          (builtins.fetchurl {
            url = "https://github.com/NixOS/nixpkgs/pull/532515.patch";
            sha256 = "1q887y71zxk5dbs7nbglr51nrmwmm5vl50c74s291bip64zglyrl";
          })
        ];
      };

      # 3. Create the nixosSystem evaluator function mapped directly to this architecture context
      customNixosSystem =
        args:
        import "${patchedNixpkgsSrc}/nixos/lib/eval-config.nix" (
          args
          // {
            inherit system lib;
            modules = args.modules ++ [
              # 4. FIX EVERYTHING: Look up and map both options from your module tree!
              ({ config, ... }: {
                _module.args.pkgs = lib.mkForce (
                  import patchedNixpkgsSrc {
                    inherit system;
                    inherit (config.nixpkgs) config overlays;
                  }
                );
              })
            ];
          }
        );
    in
    {
      # # 4. Export these parameters into the perSystem module context for withSystem to consume
      # _module.args.pkgs = patchedPkgs;
      _module.args.patchedNixosSystem = customNixosSystem;
    };
  flake.nixosConfigurations.siesta = withSystem "x86_64-linux" (
    { pkgs, patchedNixosSystem, ... }:
    patchedNixosSystem {
      specialArgs = {
        inherit self;
      };
      modules = [
        (inputs.import-tree ./_modules)
        self.users.fish
        self.nixosModules.laptop
        inputs.rehomify.nixosModules.rehomify
        {
          # Host specific declarations
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
          nix.nixPath = [ "nixpkgs=${inputs.nixpkgs}" ];
        }
      ];
    }
  );
}
