{
  self,
  lib,
  pkgs,
  ...
}:
let
  luksDevice = "/dev/disk/by-partlabel/disk-main-luks";
  devices = {
    disk.main = {
      device = "/dev/disk/by-id/ata-CT1000MX500SSD1_2132E5BE3ADF";
      type = "disk";
      content = {
        type = "gpt";
        partitions = {
          ESP = {
            size = "1G";
            type = "EF00";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
              mountOptions = [ "umask=0077" ];
            };
          };
          luks = {
            size = "100%";
            content = {
              type = "luks";
              name = "cryptroot";
              content = {
                type = "btrfs";
                extraArgs = [ "-f" ];
                subvolumes = {
                  "@" = {
                    mountpoint = "/";
                    mountOptions = [
                      "compress=zstd"
                      "noatime"
                      "ssd"
                      "discard=async"
                    ];
                  };
                  # "@home" = { mountOptions = [ "compress=zstd" ]; };
                  "@nix" = {
                    mountpoint = "/nix";
                    mountOptions = [
                      "compress=zstd"
                      "noatime"
                      "ssd"
                      "discard=async"
                    ];
                  };
                  "@swap" = {
                    mountpoint = "/swap";
                    mountOptions = [
                      "noatime"
                      "nodatacow"
                      "nodatasum"
                      "discard=async"
                    ];
                    swap = {
                      swapfile = {
                        size = "20G";
                        priority = 0;
                      };
                    };
                  };
                  "@finix-varlog" = {
                    mountpoint = "/var/log";
                    mountOptions = [
                      "compress=zstd"
                      "noatime"
                      "nodatacow"
                      "ssd"
                      "discard=async"
                    ];
                  };
                  "@finix-persist" = {
                    mountpoint = "/persist";
                    mountOptions = [
                      "compress=zstd"
                      "noatime"
                      "ssd"
                      "discard=async"
                    ];
                  };
                };
              };
            };
          };
        };
      };
    };
    nodev = {
      "/var/tmp" = {
        fsType = "tmpfs";
        mountOptions = [
          "size=2G"
          "mode=1777"
          "noatime"
          "nodev"
          "nosuid"
        ];
      };
      "/tmp" = {
        fsType = "tmpfs";
        mountOptions = [
          "size=2G"
          "mode=1777"
          "noatime"
          "nodev"
          "nosuid"
        ];
      };
    };
  };
  diskoConfig =
    (self.inputs.nixpkgs.lib.nixosSystem {
      system = pkgs.stdenv.hostPlatform.system;
      modules = [
        self.inputs.disko.nixosModules.disko
        { disko.devices = devices; }
      ];
    }).config.disko.devices._config;
in
{
  swapDevices = diskoConfig.swapDevices;
  fileSystems = lib.mkMerge [
    diskoConfig.fileSystems
    {
      cryptroot = {
        device = luksDevice;
        fsType = "luks";
        options = [ "--allow-discards" ];
      };
    }
  ];
  # imports = [
  #   inputs.disko.nixosModules.disko
  # ];
}
