{ pkgs, ... }:

# Self-hosted GitHub Actions runner for the Nova repo, so its CI runs here
# instead of on GitHub's paid minutes. The Nova workflow targets the `nova`
# label.
#
# One-time setup: create a fine-grained token at
# https://github.com/settings/personal-access-tokens with access to
# ImperaLuna/Nova only and "Administration: Read and write", then:
#   sudo install -Dm600 /dev/stdin /var/lib/secrets/github-runner-nova.token
# (paste the token, then Ctrl-D). The file stays out of the repo and the store.
{
  services.github-runners.nova = {
    enable = true;
    url = "https://github.com/ImperaLuna/Nova";
    tokenFile = "/var/lib/secrets/github-runner-nova.token";
    extraLabels = [ "nova" ];
    replace = true;
    # CI calls `nix flake check` and `nix develop`; the rest comes from the flake.
    extraPackages = [ pkgs.nix ];
  };
}
