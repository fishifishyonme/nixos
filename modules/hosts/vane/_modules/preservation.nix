{ lib, config, ... }:
{
  boot.initrd.supportedFilesystems.btrfs.enable = true;
  boot.initrd.supportedFilesystems.luks.enable = true;
  boot.initrd.finit.run.impermanence-btrfs-root = {
    runlevels = "S";
    conditions = [ "task/luks/success" ];
    script = ''
      mkdir -p /mnt
      mount /dev/mapper/cryptroot /mnt

      delete_subvolume_recursively() {
        IFS=$'\n'
        for i in $(btrfs subvolume list -o "$1" | cut -f 9- -d ' '); do
          delete_subvolume_recursively "/mnt/$i"
        done
        echo "Deleting subvolume $1"
        btrfs subvolume delete "$1"
      }
      delete_subvolume_recursively /mnt/@
      echo "Creating new root subvolume"
      btrfs subvolume create /mnt/@
      umount /mnt
    '';
  };
  boot.initrd.finit.tasks.mount-root = {
    conditions = lib.mkForce [ "run/impermanence-btrfs-root/success" ];
  };

  fileSystems = {
    # "/" = {
    #   neededForBoot = true;
    # };
    "/boot".neededForBoot = true;
    "/persist" = {
      neededForBoot = true;
    };
    "/var/log" = {
      neededForBoot = true;
    };
    "/var/tmp" = {
      neededForBoot = true;
    };
    "/swap" = {
      neededForBoot = true;
    };
  };
  preservation = {
    enable = true;
    preserveAt."/persist" = {
      files = [
        {
          file = "/etc/machine-id";
          inInitrd = true;
          how = "symlink";
          configureParent = true;
        }

        "/etc/adjtime"
      ];
      directories = [
        "/etc/ssh"
        "/var/lib/nixos"
        "/etc/nixos"
      ];
      users.fish = {
        commonMountOptions = [
          "x-gvfs-hide"
          "x-gdu.hide"
        ];
        directories = [
          "Downloads"
          "Pictures"
          "Videos"
          ".local/state/wireplumber"
          # ".var/app"
          # ".local/state/nvim"
          # ".local/share/nvim"
          ".local/state/nix"
          ".local/share/nix"
          ".config/obs-studio"
          ".config/obs-browser-plugin"
          {
            directory = ".gnupg";
            mode = "0700";
          }
          {
            directory = ".ssh";
            mode = "0700";
          }
          # {
          #   directory = ".nixops";
          #   mode = "0700";
          # }
          {
            directory = ".local/share/keyrings";
            mode = "0700";
          }
        ];
        files = [
          {
            file = ".config/htop/htoprc";
            how = "symlink";
          }
        ];
      };
    };
  };
}
