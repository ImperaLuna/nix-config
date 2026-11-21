{ ... }:
{
  # Provides /lib64/ld-linux-x86-64.so.2 so prebuilt binaries run: VS Code
  # extensions (Claude Code, ruff, ty, pgsql) and uv-managed Pythons. Claude
  # Desktop doesn't need it, since its FHS sandbox ships its own loader.
  programs.nix-ld.enable = true;
}
