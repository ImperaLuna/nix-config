{ ... }:

let
  theme = import ../../../_lib/theme.nix;
in

{
  flake.modules.homeManager.terminal-feature-bat = { pkgs, lib, ... }: {
    home.packages = [ pkgs.bat ];

    xdg.configFile."bat/config".source = ./assets/config;
    xdg.configFile."bat/themes/Carbonfox.tmTheme".text =
      builtins.replaceStrings
        [ "#ff832b" "#be95ff" "#161616" "#f9fbff" "#535353" "#25be6a" "#08bdba" ]
        [ theme.primary theme.secondary theme.bg theme.fg theme.fgAlt theme.success theme.info ]
        (builtins.readFile ./assets/themes/Carbonfox.tmTheme);

    home.activation.rebuildBatCache = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      ${pkgs.bat}/bin/bat cache --build >/dev/null 2>&1 || \
        echo "warning: failed to rebuild bat theme cache" >&2
    '';
  };
}
