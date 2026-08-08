{ pkgs, config, ... }: {
  users.users.fish = {
    isNormalUser = true;
    shell = pkgs.bash;
    passwordFile = "/persist/etc/nixos/fishPasswordFile";
    extraGroups = [
      "wheel"
      "users"
      "input"
      "audio"
      "video"
      "render"
      config.services.seatd.group
    ];
  };
}
