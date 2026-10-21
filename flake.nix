{
  description = "NixOS Configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    flake-parts.url = "github:hercules-ci/flake-parts";
    import-tree.url = "github:vic/import-tree";

    # nix-cachyos-kernel = {
    #   flake = true;
    #   type = "github";
    #   owner = "xddxdd";
    #   repo = "nix-cachyos-kernel";
    #   ref = "release";
    # };

    disko = {
      # url = "github:nix-community/disko/latest";
      url = "path:/home/fish/Documents/projects/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    impermanence = {
      url = "github:nix-community/impermanence";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "";
    };
    preservation = {
      url = "github:nix-community/preservation";
    };

    rehomify = {
      url = "github:Ryokune/rehomify";
    };

    substratum = {
      url = "github:Ryokune/substratum";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # finix.url = "github:finix-community/finix";
    finix.url = "path:/home/fish/Documents/projects/finix";
    finix-modules.url = "github:finix-community/community-modules";
  };

  outputs =
    inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
        "x86_64-darwin"
      ];

      imports = [
        (inputs.import-tree ./modules)
        inputs.disko.flakeModules.default

      ];
      debug = true;
    };
}
