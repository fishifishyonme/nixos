{ pkgs, ... }: {
  services.nftables.enable = true;
  # https://wiki.nftables.org/wiki-nftables/index.php/Quick_reference-nftables_in_10_minutes#Simple_IP/IPv6_Firewall
  # TODO: Create some firewall service instead to write these for me.
  services.nftables.configFile = pkgs.writeText "nftables.conf" ''
    flush ruleset

    table firewall {
      chain incoming {
        type filter hook input priority 0; policy drop;

        # established/related connections
        ct state established,related accept

        # loopback interface
        iifname lo accept

        # icmp
        icmp type echo-request accept

        # open tcp ports: sshd (22)
        tcp dport { 22 } accept

        # Avahi (mDNS) – needed for service discovery
        udp dport 5353 accept
      }
    }

    table ip6 firewall {
      chain incoming {
        type filter hook input priority 0; policy drop;

        # established/related connections
        ct state established,related accept

        # invalid connections
        ct state invalid drop

        # loopback interface
        iifname lo accept

        # icmp
        # routers may also want: mld-listener-query, nd-router-solicit
        icmpv6 type { echo-request, nd-neighbor-solicit } accept

        # open tcp ports: sshd (22)
        tcp dport { 22 } accept

        # Avahi (mDNS) – needed for service discovery over IPv6
        udp dport 5353 accept
      }
    }
  '';
}
