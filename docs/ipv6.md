# IPv6

## Status

IPv6 is **disabled** on both hosts (laptop: DuskNova, desktop: RyzenShine) via:

```nix
networking.enableIPv6 = false;
```

Located in:
- `hosts/laptop/default.nix`
- `hosts/desktop/default.nix`

## IPv4 Preference (gai.conf)

Even with IPv6 disabled, some apps (e.g. Codex) still attempt IPv6 connections first via DNS AAAA records, causing timeouts before falling back to IPv4.

To fix this, both hosts have a `gai.conf` entry that forces the system to prefer IPv4:

```nix
environment.etc."gai.conf".text = ''
  precedence ::ffff:0:0/96  100
'';
```

This tells `getaddrinfo()` to always rank IPv4-mapped addresses higher than IPv6, so apps connect via IPv4 immediately.

## Known Issues

- IPv6-related breakage may be related to NetworkManager. If networking behaves unexpectedly after changes, NetworkManager is a likely suspect — investigate before changing anything else.
