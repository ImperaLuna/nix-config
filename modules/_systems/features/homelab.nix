{ lib, pkgs, ... }:

{
  services.k3s = {
    enable = true;
    role = "server";
    extraFlags = [
      "--write-kubeconfig-mode 0644"
    ];
  };

  services.tailscale = {
    enable = lib.mkDefault true;
    openFirewall = lib.mkDefault true;
    useRoutingFeatures = lib.mkDefault "server";
  };

  services.adguardhome = {
    enable = true;
    host = "0.0.0.0";
    port = 8088;
    mutableSettings = true;
    settings = {
      dns = {
        bind_hosts = [ "0.0.0.0" ];
        port = 53;
        upstream_dns = [ "127.0.0.1:5335" ];
      };
    };
  };

  services.unbound = {
    enable = true;
    resolveLocalQueries = false;
    settings = {
      server = {
        interface = [ "0.0.0.0@5335" ];
        do-ip4 = true;
        do-ip6 = true;
        do-udp = true;
        do-tcp = true;
        hide-identity = true;
        hide-version = true;
        harden-glue = true;
        harden-dnssec-stripped = true;
        use-caps-for-id = true;
        prefetch = true;
        prefetch-key = true;
        access-control = [
          "127.0.0.1/8 allow"
          "192.168.0.0/16 allow"
          "172.16.0.0/12 allow"
          "0.0.0.0/0 allow"
        ];
      };
      "forward-zone" = [
        {
          name = ".";
          forward-addr = "9.9.9.10";
        }
      ];
    };
  };

  systemd.tmpfiles.rules = [
    "d /mnt/data 0755 root root -"
    "d /mnt/data/adguard 0755 root root -"
    "d /mnt/data/adguard/conf 0755 root root -"
    "d /mnt/data/adguard/work 0755 root root -"
    "d /mnt/data/homarr 0755 root root -"
  ];

  networking.firewall.allowedTCPPorts = [
    53
    80
    443
    8088
    3000
    5335
    6443
  ];
  networking.firewall.allowedUDPPorts = [ 53 ];

  environment.systemPackages = with pkgs; [
    kubectl
    kustomize
    kubeseal
    openssl
  ];
}
