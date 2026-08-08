{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    vim
    git
    wget
    iputils
    iproute2
    nixos-rebuild-ng
    vulkan-tools
    vulkan-loader
    htop
    nh # hoppefully u uwoorkkk
  ];
  environment.variables = {
    NH_OS_FLAKE = "/etc/nixos";
  };
}
