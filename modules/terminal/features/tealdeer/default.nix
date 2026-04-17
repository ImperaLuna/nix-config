{ self, inputs, ... }:

{
  perSystem = { pkgs, ... }: {
    packages.terminal-tealdeer = inputs.nix-wrapper-modules.wrappers.tealdeer.wrap {
      inherit pkgs;

      settings = {
        updates = {
          auto_update = true;
          auto_update_interval_hours = 24;
        };

        style.command_name.foreground.rgb = {
          r = 253;
          g = 112;
          b = 20;
        };

        style.example_code.foreground.rgb = {
          r = 253;
          g = 112;
          b = 20;
        };
      };
    };
  };

  flake.modules.homeManager.terminal-feature-tealdeer = { pkgs, lib, ... }:
    let
      tealdeerPkg = self.packages.${pkgs.stdenv.hostPlatform.system}.terminal-tealdeer;
    in
    {
      home.packages = [ tealdeerPkg ];

      home.activation.updateTealdeerCache = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        cache_dir="$HOME/.cache/tealdeer/pages"

        if [ ! -d "$cache_dir" ] || [ -z "$(
          ${pkgs.findutils}/bin/find "$cache_dir" -type f -print -quit 2>/dev/null
        )" ]; then
          ${tealdeerPkg}/bin/tldr --update >/dev/null 2>&1 || \
            echo "warning: failed to initialize tealdeer cache" >&2
        fi
      '';
    };
}
