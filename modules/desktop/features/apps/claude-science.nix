{ ... }:

{
  # Claude Science installs and updates itself in ~/.local/bin (see the
  # NixOS side in __hosts/_systems/features/claude-science.nix).
  flake.modules.homeManager.apps-feature-claude-science = { ... }: {
    home.sessionPath = [ "$HOME/.local/bin" ];
  };
}
