{ lib, pkgs, ... }:

# Self-hosted GitHub Actions runners for the Nova repo, so its CI runs here
# instead of on GitHub's paid minutes. The Nova workflow targets the `nova`
# label. Two instances, so two PRs' checks run side by side instead of
# queueing; both register with the same token file.
#
# One-time setup: create a fine-grained token at
# https://github.com/settings/personal-access-tokens with access to
# ImperaLuna/Nova only and "Administration: Read and write", then:
#   sudo install -Dm600 /dev/stdin /var/lib/secrets/github-runner-nova.token
# (paste the token, then Ctrl-D). The file stays out of the repo and the store.
let
  # Replaces the single `nova` instance. GitHub drops the old, offline runner
  # on its own, or remove it under Settings > Actions > Runners.
  instances = [
    "nova-1"
    "nova-2"
  ];
in
{
  # The runner name defaults to the attribute name, so each instance
  # registers as nova-1 or nova-2.
  services.github-runners = lib.genAttrs instances (_: {
    enable = true;
    url = "https://github.com/ImperaLuna/Nova";
    tokenFile = "/var/lib/secrets/github-runner-nova.token";
    extraLabels = [ "nova" ];
    replace = true;
    # One job per registration: after each job the runner de-registers,
    # systemd wipes its workspace and it registers again. So nothing a PR
    # branch leaves behind (a git hook in the checkout, say) reaches the next
    # job. Needs the token file to hold a PAT, which it does.
    ephemeral = true;
    # CI calls `nix flake check` and `nix develop`; the rest comes from the flake.
    extraPackages = [ pkgs.nix ];
  });

  # CI builds, including the NixOS VM tests (which use KVM), run inside the
  # nix daemon, not the runner. Give them leftover CPU and disk time only, so
  # the desktop and local testing stay responsive while CI runs.
  nix.daemonCPUSchedPolicy = "batch";
  nix.daemonIOSchedClass = "idle";
}
