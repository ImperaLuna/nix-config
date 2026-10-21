{ inputs, ... }:

{
  flake.modules.homeManager.apps-feature-claude-desktop = { pkgs, ... }:
  let
    # Built from Anthropic's official Linux .deb; not in nixpkgs.
    claudeDesktop = inputs.claude-desktop.packages.${pkgs.stdenv.hostPlatform.system}.default;
  in
  {
    home.packages = [
      (pkgs.symlinkJoin {
        name = "claude-desktop-libsecret";
        paths = [ claudeDesktop ];
        nativeBuildInputs = [ pkgs.makeWrapper ];
        postBuild = ''
          # Electron picks its secret backend from XDG_CURRENT_DESKTOP, and niri
          # is unrecognised, so it stores no sign-in without being told.
          wrapProgram $out/bin/claude-desktop \
            --add-flags "--password-store=gnome-libsecret"

          # Upstream's desktop entries hardcode the unwrapped store path, which
          # would skip the wrapper when launched from a menu.
          for f in $out/share/applications/*.desktop; do
            target=$(readlink -f "$f")
            rm "$f"
            sed "s|${claudeDesktop}/bin/claude-desktop|$out/bin/claude-desktop|g" \
              "$target" >"$f"
          done
        '';
      })
    ];
  };
}
