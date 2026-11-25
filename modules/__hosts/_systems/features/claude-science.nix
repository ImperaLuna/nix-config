{ pkgs, ... }:

{
  # Claude Science has no Nix package. Its installer
  # (curl -fsSL https://claude.ai/install-claude-science.sh | bash) puts a
  # self-updating glibc binary in ~/.local/bin, which runs through nix-ld.
  # The sandbox runs bwrap and socat only from system folders, never PATH;
  # /run/current-system/sw/bin counts. Saving to granted folders needs
  # python3 at exactly /usr/bin/python3.
  environment.systemPackages = with pkgs; [ bubblewrap socat python3 ];

  system.activationScripts.claude-science-python = ''
    mkdir -p /usr/bin
    ln -sf /run/current-system/sw/bin/python3 /usr/bin/python3
  '';
}
