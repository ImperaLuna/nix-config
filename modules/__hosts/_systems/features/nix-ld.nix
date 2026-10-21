{ ... }:
{
  # Claude Desktop downloads its own generic-linux claude-code binary and runs
  # it from ~/.config, so it needs a real loader. It only links against glibc,
  # which nix-ld provides by default.
  programs.nix-ld.enable = true;
}
