{ self, ... }:
{
  flake.nixosModules.waydroid =
    {
      lib,
      config,
      pkgs,
      ...
    }:
    with lib;
    let
      cfg = config.services.waydroid;
    in
    {
      options.services.waydroid = {
        enable = mkEnableOption "waydroid-container Service";
      };
      config = mkIf cfg.enable {

        networking.firewall.trustedInterfaces = [ "waydroid0" ];

        virtualisation.waydroid = {
          enable = true;
          package = if config.networking.nftables.enable then pkgs.waydroid-nftables else pkgs.waydroid;
        };

        # Improves the existing service
        # TODO: Just change the waydroid_base file once?
        systemd.services.waydroid-container = {
          serviceConfig = {
            # Enable cgroups v2 delegation (fixes "Read-only file system" errors)
            Delegate = true;
            CPUAccounting = true;
            MemoryAccounting = true;
            TasksAccounting = true;
            ExecStartPre = mkAfter [
              (pkgs.writeShellScript "waydroid-gpu-fix-pre" ''
                set -e
                PROP_FILE="/var/lib/waydroid/waydroid_base.prop"
                LXC_FILE="/var/lib/waydroid/lxc/waydroid/config"

                mkdir -p /var/lib/waydroid
                touch "$PROP_FILE"
                chown root:root "$PROP_FILE"
                chmod 644 "$PROP_FILE"

                # Function to set properties (removes old, adds new)
                set_prop() {
                  ${pkgs.gnused}/bin/sed -i "/^$1=/d" "$PROP_FILE"
                  echo "$1=$2" >> "$PROP_FILE"
                }

                set_lxc() {
                  ${pkgs.gnused}/bin/sed -i "/^$1 = /d" "$LXC_FILE"
                  echo "$1 = $2" >> "$LXC_FILE"
                }

                # Force Intel GPU (GBM/Mesa)
                set_prop ro.hardware.gralloc minigbm_gbm_mesa
                set_prop ro.hardware.egl mesa
                set_prop ro.hardware.vulkan intel

                set_lxc lxc.net.0.mtu 1358

                # Clean empty lines
                # ${pkgs.gnused}/bin/sed -i '/^$/d' "$PROP_FILE"
              '')
            ];
          };
        };
      };
    };
}
